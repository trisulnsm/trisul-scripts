-- tls-monitor.lua
--
-- A new countergroup with 1 meter. Monitors TLS record types seen 
-- on wire. (All except Application Data) 
--
-- 
-- Meter 0 =  Number of records  
--
TrisulPlugin = {

  id = {
    name = "TLS Record",
    description = "Count SSL/TLS record types ",
    author = "Unleash", version_major = 1, version_minor = 0,
  },

  countergroup = {
    control = {
      guid = "{fc970d3a-5a39-4e31-a687-672c5174a58e}",
      name = "TLSRec",
      description = "Record types",
      bucketsize = 30,
    },

    meters = {
        {  0, T.K.vartype.COUNTER,	 10, "Hits", "Hits",    "hits" },
    },  

  },

 
  -- the "key format" is contentype/handshaketype  
  --
  flowmonitor  = {

	onflowattribute = function(engine,flow,timestamp, nm, valbuff)


	     if nm == "TLS:RECORD" then
		 	local  content_type = valbuff:hval_8(0)
			local  handshake_type = 0

			if content_type == 22 then handshake_type = valbuff:hval_8(5) end 

			local keystr = string.format("%d/%d", content_type, handshake_type)

			engine:update_counter("{fc970d3a-5a39-4e31-a687-672c5174a58e}", 
						keystr, 0, 1)

		 end
		 
    end,

  },


}

