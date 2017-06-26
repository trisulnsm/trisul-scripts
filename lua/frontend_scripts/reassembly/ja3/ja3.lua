--
-- ja3.lua
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Client Hello fingerprint IOC experimental 
-- DESCRIPTION: Trying out https://github.com/salesforce/ja3
-- 


-- Setup LUAJIT2.1 FFI into libcrypto.so for MD5 
local ffi=require('ffi')
local C = ffi.load('libcrypto.so.1.0.0')
local dbg=require'debugger'

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

-- helpers to parse binary records 
local xtractors = {

  u8 = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)
  end,

  next_u8 = function(tbl)
    local r = tbl:u8()
    tbl:inc(1)
    return r
  end,

  next_u8_arr = function(tbl,nitems)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u8()
      nitems = nitems - 1
    end
    return ret;
  end,

  next_u16 = function(tbl)
    return tbl:next_u8()*256 + tbl:next_u8()
  end,

  next_u16_arr = function(tbl,nitems)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u16()
      nitems = nitems - 1
    end
    return ret;
  end,

  next_u24 = function(tbl)
    return tbl:next_u8()*4096 + tbl:next_u8()*256 + tbl:next_u8()
  end,

  next_u32 = function(tbl)
    return tbl:next_u16()*65536 + tbl:next_u16() 
  end,

  inc = function(tbl, n)
    tbl.seekpos = tbl.seekpos + n 
  end,

  skip = function(tbl, n)
    tbl.seekpos = tbl.seekpos + n 
    return true
  end,

  reset = function(tbl)
    tbl.seekpos=1
    fence=#tbl.buff
  end,

  has_more = function(tbl)
    return tbl.seekpos < tbl.fence
  end,

  set_fence = function(tbl,delta_ahead)
    fence = tbl.seekpos + delta_ahead
  end ,

  reset_fence = function(tbl)
    fence=#tbl.buff
  end,

}

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

  -- a new JA3 resource 
  -- 
  resourcegroup  = {

    control = {
      guid = "{E8D3E68F-B320-49F3-C83D-66751C3B485F}",
      name = "JA3 TLS",
      description = "JA3 TLS Client Hello Hash",
    },

  },
 
  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- we want to see TLS:RECORD 
    -- 
    onattribute = function(engine, timestamp, flowkey, attr_name, attr_value) 

    if attr_name ~= "TLS:RECORD" then return;  end 

    local payload = {
      buff = attr_value,
      seekpos = 1,
      fence=#attr_value,
    }
    setmetatable( payload, { __index = xtractors } )

    -- handshake only + client_hello only
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
      payload:next_u24()                  -- over handshake_length 
      ja3f.SSLVersion = payload:next_u16()
      payload:skip(32)                    -- over client_random
      payload:skip(payload:next_u8())     -- over SessionID if present 

      ja3f.Cipher = payload:next_u16_arr( payload:next_u16()/2) 

      payload:skip(payload:next_u8())     -- over compression 
      payload:set_fence(payload:next_u16())

      while payload:has_more() do
        local ext_type = payload:next_u16()
        local ext_len =  payload:next_u16()
        if ext_type == 10 then
           ja3f.EllipticCurve  = payload:next_u16_arr( payload:next_u16()/2)
        elseif ext_type == 11 then
           ja3f.EllipticCurvePointFormat = payload:next_u8_arr( payload:next_u8())
        else 
          payload:skip(ext_len)
        end

        ja3f.SSLExtension[#ja3f.SSLExtension+1]=ext_type 
      end

	  -- kick out GREASE extensions  from all tables (see RFC) 
	  for _, ja3f_tbl in ipairs( { ja3f.Cipher, ja3f.SSLExtension, ja3f.EllipticCurve} ) do 
		  for i, v in ipairs(ja3f_tbl) do 
			if  GREASE_tbl[v] then ja3f_tbl[i]=0;  end
		  end
	  end 


      local ja3_str = ja3f.SSLVersion .. "," ..
               table.concat(ja3f.Cipher,"-")..","..
               table.concat(ja3f.SSLExtension,"-")..","..
               table.concat(ja3f.EllipticCurve,"-")..","..
               table.concat(ja3f.EllipticCurvePointFormat,"-")
      local ja3_hash = md5sum(ja3_str)

      -- print("string = ".. ja3_str.. " hash="..md5sum(ja3_str))
      engine:add_resource('{E8D3E68F-B320-49F3-C83D-66751C3B485F}', -- the JA3 resource guid
        flowkey:id(),
        ja3_hash,
        ja3_str)

    end
    
  end,    

  },

}
