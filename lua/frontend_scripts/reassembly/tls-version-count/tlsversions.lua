-- tlsversions.lua
-- 
-- Counts TLS Versions 
-- 
local SWP=require'sweepbuf'

TrisulPlugin = {

  id =  {
    name = "tlsversions ",
    description = "meters TLS versions per flow",
  },


  reassembly_handler  = {

    -- latch on to port 443 (HTTPS) ; no interest in others
    filter = function(engine, timestamp, flow )

      return  flow:porta_readable() == "443" or 
              flow:portz_readable() == "443"  

    end,

    -- we want to see TLS:RECORD for PRINTS and User-Agents for HTTP 
    -- 
    onattribute = function(engine, timestamp, flowkey, attr_name, attr_value) 


      if attr_name ~= "TLS:RECORD" then return;  end 
      
      local payload = SWP.new(attr_value)

      -- Only interested in TLS handshake (type = 22) + client_hello only
      if payload:next_u8() == 22 and payload:skip(4) and payload:next_u8()==2 then

        payload:reset()
        payload:inc(5)
        payload:next_u8()                    -- over handshake_type

        -- validate , sometimes encrypted handshake can misfire 
        local hslen=payload:next_u24()                  
        if hslen ~= #attr_value - 9 then return end;

        local hs_version=payload:next_u16() -- over TLS version 
        payload:skip(32)                    -- over client_random
        payload:skip(payload:next_u8())     -- over SessionID if present 
        payload:next_u16()                  -- cipher 
        payload:skip(1)                     -- over compression 


        if not payload:has_more() then return end


        -- extensions length
        payload:push_fence(payload:next_u16())


        -- search for supported_version(43) extension 
        local version = nil 
        while payload:has_more() do
          local ext_type = payload:next_u16()
          local ext_len =  payload:next_u16()
          if ext_type == 43 then
            version = payload:next_uN(ext_len) 
          else
            payload:skip(ext_len)
          end
        end

        -- if no version in server hello extension, then use the TLS version in SH
        if version == nil then
          version = hs_version
        end

        -- meter the version here 
        engine:update_counter("{44DBB4E0-B79F-4FB5-A437-3CFEDFB7B65E}",
                    tostring(version),
                    1,
                    1)

        engine:add_flow_counter(flowkey:id(),
                    "{44DBB4E0-B79F-4FB5-A437-3CFEDFB7B65E}",
                    tostring(version),
                    0,
                    0)

        -- edges to flows
        engine:add_flow_edges(flowkey:id(),
                    "{44DBB4E0-B79F-4FB5-A437-3CFEDFB7B65E}",
                    tostring(version))

        -- we're done with this flow, 
        -- if no other plugin in interested then Trisul will stop reassembling 
        engine:disable_reassembly(flowkey:id())

      end
    end,    
  },

-- countergroup block
  -- 
  countergroup = {

    -- control table 
  -- specify details of your new counter group you can use 
  -- 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{44DBB4E0-B79F-4FB5-A437-3CFEDFB7B65E}",
      name = "TLS Versions",
      description = "Count volume flows per TLS version",
      bucketsize = 30,
    },


    meters = {
        {  0, T.K.vartype.RATE_COUNTER, 10, 0, "Packets", "bytes",    "Bps" },
        {  1, T.K.vartype.COUNTER,      10, 0, "Flows",   "flows",    "Flws" },
    },  

    -- key mapping
    -- maps keys used by you into user friendly names for Trisul display 
    keyinfo = {
      {"768","SSL 3.0"},
      {"769","TLS 1.0"},
      {"770","TLS 1.1"},
      {"771","TLS 1.2"},
      {"772","TLS 1.3"},
    }

  },

}
