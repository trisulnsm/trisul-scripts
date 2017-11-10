--
-- tlsfingerprint.lua
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Client Hello fingerprint IOC experimental 
-- DESCRIPTION: Implements https://github.com/synackpse/tls-fingerprinting
--              and  https://github.com/salesforce/ja3
--
-- 

-- Setup LUAJIT2.1 FFI into libcrypto.so for MD5 
local ffi=require('ffi')
local C = ffi.load('libcrypto.so.1.0.0')
local SWP = require'sweepbuf' 
local JSON = require'JSON' 

-- local dbg=require'debugger'

ffi.cdef[[
    typedef struct MD5state_st
    {
    unsigned int A,B,C,D;
    unsigned int Nl,Nh;
    unsigned int data[16];
    unsigned int num;
    } MD5_CTX;
  int MD5_Init(MD5_CTX *c);
  int MD5_Update(MD5_CTX *c, const void *data, size_t len);
  int MD5_Final(unsigned char *md, MD5_CTX *c);

]]
-- ffi based MD5 
function md5sum( input)
    local hashresults = ffi.new("uint8_t[16]")
    ctx = ffi.new'MD5_CTX'
    C.MD5_Init(ctx)
    C.MD5_Update(ctx,input,#input)
    C.MD5_Final(hashresults,ctx)
    return T.util.bin2hex(ffi.string(hashresults,16)) 
end 

-- you dont want to be messing with these
-- hi there Chromium !!  https://tools.ietf.org/html/draft-davidben-tls-grease-00
local GREASE_tbl =
{
      [0x0A0A] = true,
      [0x1A1A] = true,
      [0x2A2A] = true,
      [0x3A3A] = true,
      [0x4A4A] = true,
      [0x5A5A] = true,
      [0x6A6A] = true,
      [0x7A7A] = true,
      [0x8A8A] = true,
      [0x9A9A] = true,
      [0xAAAA] = true,
      [0xBABA] = true,
      [0xCACA] = true,
      [0xDADA] = true,
      [0xEAEA] = true,
      [0xFAFA] = true
};


-- plugin ; reassembly_handler + resource_group 
TrisulPlugin = { 

  id =  {
    name = "ja3 hash",
    description = "a client_hello hash ",
  },


  -- read the JSON 
  -- 
  onload = function()

    local prints_file = T.env.get_config("App>DataDirectory").."/tls-fingerprints.json" 

  local f, err = io.open(prints_file)
  if not f then
    T.logerror("Unable to open TLS Fingerprints JSON file"..err)
    return false
  end

  T.log("Prints file="..prints_file);
  T.print_tbl = { } 

  local cnt=0
  for oneline in f:lines() do
    local jj = JSON:decode(oneline)
    if jj then 
      T.print_tbl[jj["ja3_hash"]]=jj["desc"]
      cnt=cnt+1
    end
  end

  T.log("Loaded "..cnt.." TLS fingerprints")

  f:close()
  end,

  -- a new JA3 PRINT counter stream
  -- 
  countergroup   = {

    control = {
      guid = "{E8D5E68F-B320-49F3-C83D-66751C3B485F}",
      name = "JA3 PRINT",
      description = "JA3 TLS Client Hello Hash",
      bucketsize = 60,
    },

    meters = {
      {0, T.K.vartype.COUNTER, 20, "Hits", "hits",    "hits" },
    },  
  },
 
  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- we want to see TLS:RECORD for PRINTS and User-Agents for HTTP 
    -- 
    onattribute = function(engine, timestamp, flowkey, attr_name, attr_value) 


    if attr_name == "User-Agent" then
        engine:add_flow_edges(flowkey:id(), '{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}', attr_value:sub(10))
        return
    end 


    if attr_name ~= "TLS:RECORD" then return;  end 

    local payload = SWP.new(attr_value)

    -- Only interested in TLS handshake (type = 22) + client_hello only
    if payload:next_u8() == 22 and payload:skip(4) and payload:next_u8() == 1 then

      payload:reset()
      payload:inc(5)


      -- per JA3 they want these fields, 
      -- https://github.com/salesforce/ja3
      local ja3f = {
        SSLVersion="",
        Cipher={},
        SSLExtension={},
        EllipticCurve={},
        EllipticCurvePointFormat={}
      }

      payload:next_u8()                   -- over handshake_type

      -- validate , sometimes encrypted handshake can misfire 
      local hslen=payload:next_u24()                  
      if hslen ~= #attr_value - 9 then return end;

      ja3f.SSLVersion = payload:next_u16() 
      payload:skip(32)                    -- over client_random
      payload:skip(payload:next_u8())     -- over SessionID if present 

      ja3f.Cipher = payload:next_u16_arr( payload:next_u16()/2) 

      payload:skip(payload:next_u8())     -- over compression 

      -- extensions, we pick out SNI as well if 
      payload:push_fence(payload:next_u16())

      local snihostname  = nil 

      while payload:has_more() do
        local ext_type = payload:next_u16()
        local ext_len =  payload:next_u16()
        if ext_type == 10 then
          ja3f.EllipticCurve  = payload:next_u16_arr( payload:next_u16()/2)
        elseif ext_type == 11 then
           ja3f.EllipticCurvePointFormat = payload:next_u8_arr( payload:next_u8())
        elseif ext_type ==  0 then 
          payload:push_fence(payload:next_u16())
          while payload:has_more() do
            payload:skip(1)
            snihostname  =  payload:next_str_to_len(payload:next_u16())
          end
          payload:pop_fence()
        else 
          payload:skip(ext_len)
        end

        -- skip the padding extension 
        if ext_type ~= 21 then 
          ja3f.SSLExtension[#ja3f.SSLExtension+1]=ext_type 
        end 
      end


      -- kick out GREASE values  from all tables (see RFC) 
      -- since they can appear at random positions (generating a different hash)
      -- we need to remove them completely 
      for _, ja3f_tbl in ipairs( { ja3f.Cipher, ja3f.SSLExtension, ja3f.EllipticCurve} ) do 
        for i=#ja3f_tbl,1,-1 do
          if  GREASE_tbl[ja3f_tbl[i]] then table.remove(ja3f_tbl,i);  end
        end
      end 


      local ja3_str = ja3f.SSLVersion .. "," ..
               table.concat(ja3f.Cipher,"-")..","..
               table.concat(ja3f.SSLExtension,"-")..","..
               table.concat(ja3f.EllipticCurve,"-")..","..
               table.concat(ja3f.EllipticCurvePointFormat,"-")
      local ja3_hash = md5sum(ja3_str)


      print(" flow=".. flowkey:to_s().." hash ".. ja3_hash.. " string="..ja3_str)

      -- counters and edges 
      engine:update_counter('{E8D5E68F-B320-49F3-C83D-66751C3B485F}', ja3_hash, 0, 1)

      -- see if this is a known hash 
      local client_desc = T.print_tbl[ja3_hash]
      if client_desc then
        engine:update_key_info('{E8D5E68F-B320-49F3-C83D-66751C3B485F}', ja3_hash, client_desc)
        engine:add_edge('{E8D5E68F-B320-49F3-C83D-66751C3B485F}', ja3_hash, 
                    '{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}', client_desc)
      end

      -- Streaming Graph Analytics : Add Bi-Directional Edge 
      engine:add_edge('{E8D5E68F-B320-49F3-C83D-66751C3B485F}', ja3_hash, 
                        '{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}', snihostname)

      engine:add_edge('{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}', snihostname, 
              '{E8D5E68F-B320-49F3-C83D-66751C3B485F}', ja3_hash )

      -- Add Flow edges for both SNI and HASH 
      engine:add_flow_edges(flowkey:id(), '{B91A8AD4-C6B6-4FBC-E862-FF94BC204A35}', snihostname)
      engine:add_flow_edges(flowkey:id(), '{E8D5E68F-B320-49F3-C83D-66751C3B485F}', ja3_hash)

    end
    
  end,    

  },
}
