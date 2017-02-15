-- tlsalert.lua
-- 
-- Sample Trisul Network Analytics LUA script
--
-- Generates a custom alert when obsolete TLS versions ( < TLS 1.2 ) are seen 
-- 
-- one alert for each flow ! 
--
-- Demonstrates How To using the LUA API :
-- 
-- 1. How to ask for first 10K bytes of reassembled data of every SSL/TLS stream
-- 2. How to check header values
-- 3. How to generate custom  alerts
--
--  author : vivekr 

TrisulPlugin = {

  id =  {
    name = "tlsalert",
    description = "alert on obsolete TLS versions ",
  },


  reassembly_handler  = {


    -- latch on to port 443 (HTTPS) ; no interest in others
    -- 
    -- perf tip: another way is to use regex on flow key (refer to Trisul Flow Key format documentation)
    -- if flow:id():match("p-01BB")  then ... end 
    --
    filter = function(engine, timestamp, flow )

      if flow:porta_readable() == "443" or flow:portz_readable() == "443"  then
        return true
      else
        return false
      end
      -- return flow:id():match("p-01BB") 

    end,

    --
    -- called when a chunk of reassembled data is available 
    -- 
    -- APP NOTE :  We ignore the Version numbers in the TLS HANDSHAKE
    --             protocols, if we see APPDATA using an obsolete
    --             version, we alert. This means that both sides 
    --             have downgraded and are exchanging traffic using
    --             older version 
    -- 
    onpayload  = function(engine, time, flow, dir, seekpos, buff )

      local hs_type = buff:hval_8(0)

      if hs_type == 0x17 then

        local tls_version_major   = buff:hval_8(1)
        local tls_version_minor   = buff:hval_8(2)

        if ( tls_version_major < 3 ) then

          engine:add_alert("{5E97C3A3-41DB-4e34-92C3-87C904FAB83E}",
            flow:id(), 
			"OBSOLETE_TLS_VER", 
			1,
            "Seen old SSLv3 TLS traffic maj="..tls_version_major.." min="..tls_version_minor);
        
        elseif tls_version_major ==  3 and  tls_version_minor < 3 then

          engine:add_alert("{5E97C3A3-41DB-4e34-92C3-87C904FAB83E}",
            flow:id(), 
			"OBSOLETE_TLS_VER", 
			1,
            "Seen Older TLS version traffic maj="..tls_version_major.." min="..tls_version_minor);

        end

        engine:disable_reassembly( flow:id() )

      end

    end
        
  },

}
