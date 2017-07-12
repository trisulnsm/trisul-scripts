--
-- packet_storage.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Dont store SSL traffic on Port 443
-- DESCRIPTION: No point storing SSL traffic on Port 443, but store non-SSL traffic
--	            since a lot of applications are now using Port 443. Use the 
--              filter_payload(..) method to check the start of Flow Bytes for TLS prints
--
--
-- 
-- 
-- local dbg=require'debugger'
TrisulPlugin = { 

  id =  {
    name = "No PCAP TLS", description = "No PCAP TLS ", author = "Unleash", 
  },

  -- packet_storage block;
  --
  packet_storage   = {

    -- WHEN CALLED: the first reassembled chunk in each direction is seen
    -- use this if you need to see the actual first few bytes of the flow 
    -- before you decide you want to store the flow or not 
    filter_payload = function(engine, timestamp, flowkey, direction, seekpos, buff) 

		-- we arent handling non Port 443, return -1 for (no opinion) 
		if flowkey:id():find("p-01BB") == nil then return -1 end 

		-- if TLS/SSL fingerprint 
		local hs_type             = buff:hval_8(0)
		local tls_version_major   = buff:hval_8(1)
		local tls_version_minor   = buff:hval_8(2)


		if hs_type == 22 and tls_version_major ==3 and tls_version_minor < 4 then 
			--
			-- looks like TLS , ignore 
			--
			return 0

		elseif flowkey:protocol()=='11' and buff:tostring(9,4) == "Q035" then 
			-- looks like Google Chrome's QUIC , ignore 
			return 0
		else 
			--
			-- return -1 , no opinion. use the default policy
			--
			print("Non TLS or QUIC traffic on Port 443="..flowkey:id())
			return -1
	    end
    end,    

  },
}
