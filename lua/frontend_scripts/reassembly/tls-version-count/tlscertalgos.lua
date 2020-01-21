--
-- tls_certalogs.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Metrics for signature and public key algorithms, 
--              if using ECC the curve name 
-- 
-- how this script works :  listens to SSL Certs FTS stream and parses the 
-- cert chain as a string 
-- 
TrisulPlugin = { 

  id =  {
    name = "Public Key algorithm monitor",
    description = "Alert on sign algo ",
  },



  fts_monitor  = {

    -- attach to the FTS/SSL Certs stream 
    fts_guid = function()  
      return T.ftsgroups['SSL Certs']
    end, 



    -- a new doc passing by stream 
    onnewfts  = function(engine, fts )

      local certchain = fts:text()

		local pos=1
		local _, nextpos=certchain:find("-----END CERTIFICATE-----",pos, true) 
		while nextpos do

			local c = certchain:sub(pos, nextpos);
			local cn = c:match("CN=([%S ]+)\n")
			local sig = c:match("Signature Algorithm: (%S+)\n")
			local pkalgo = c:match("Public Key Algorithm: (%S+)\n")
			if pkalgo == "id-ecPublicKey" then
				pkalgo  = c:match("ASN1 OID: (%S+)\n")
				if pkalgo == nil then
					pkalgo  = "explicit-ec-curve" 
				else
					pkalgo  = "curve:"..pkalgo 
				end 
			end

			pos=nextpos
			_,nextpos=certchain:find("-----END CERTIFICATE-----",pos, true) 

			-- update signature algo 
			engine:update_counter("{C90640F6-ACD1-4BE5-92FF-A417DC6A987A}",sig,0,1)
			
			-- update public key algo 
			engine:update_counter("{88F603AE-4519-4E3D-E1C8-D1882E398724}",pkalgo,0,1)

			-- add an edge PK algo -> CN 
			engine:add_edge("{88F603AE-4519-4E3D-E1C8-D1882E398724}",pkalgo,"{432D7552-0363-4640-9CC5-23E4CA8410EA}", cn)

			-- add an edge SIG algo -> CN 
			engine:add_edge("{C90640F6-ACD1-4BE5-92FF-A417DC6A987A}",sig,"{432D7552-0363-4640-9CC5-23E4CA8410EA}", cn)

		end 

    end,

  },
}
