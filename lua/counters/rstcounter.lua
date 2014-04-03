-- rstcounter.lua
--
-- A new countergroup with 2 meters
-- 
-- Meter 0 =  Total bandwidth 
-- Meter 1 =  Number of RST packets seen 
--
-- Demonstrates 
--   1. Use find_layer(..) to get the IP layer 
--   2. Create Trisul Host format keys 
--
TrisulPlugin = {

  id = {
    name = "TCP Flags",
    description = "Count TCP Flags ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  countergroup = {
    control = {
      guid = "{a973e25d-4434-4f0a-9656-9d2c0247eaf8}",
      name = "Host TCP",
      description = "Count volume and  TCP flags in all packets",
      bucketsize = 30,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER, 10, "Packets", "bytes",    "Bps" },
        {  1, T.K.vartype.COUNTER,      10, "Resets",  "packets",  "Pkts" },
    },  
  },

  simplecounter = {

  	-- we want to hook to TCP layer 
    protocol_guid = "{77E462AB-2E42-42ec-9A58-C1A6821D6B31}",

    -- onpacket
	--  called for each TCP packet with layer = TCP 
    onpacket = function(engine,layer)

	  --
	  -- find layer gets you a IP layer
	  --
      local iplayer = layer:packet():find_layer("{0A2C724B-5B9F-4ba6-9C97-B05080558574}")
      local ipbuff = iplayer:rawbytes()

	  --
	  -- converts the IP addresses into trisul key format C0.A8.01.02
	  --
      local sipkey =  string.format("%02X.%02X.%02X.%02X",  
	  		ipbuff:hval_8(12), ipbuff:hval_8(13), ipbuff:hval_8(14), ipbuff:hval_8(15))
      local dipkey =  string.format("%02X.%02X.%02X.%02X",  
	  		ipbuff:hval_8(16), ipbuff:hval_8(17), ipbuff:hval_8(18), ipbuff:hval_8(19)) 

	  --
	  -- meter both source and dest IPs total volume (meter 0)
	  --
      engine:update_counter_bytes(TrisulPlugin.countergroup.control.guid, sipkey , 0)
      engine:update_counter_bytes(TrisulPlugin.countergroup.control.guid, dipkey , 0)

	  -- 
	  -- get the TCP header to count RST 
	  --
      local buff = layer:rawbytes()
      local flag_bytes = buff:hval_16(12)
      local resetflag = bit32.extract(flag_bytes,2)

      if tonumber(resetflag) == 1 then
	  	 --
		 -- Update meter 1, we found RST flag 
         engine:update_counter(TrisulPlugin.countergroup.control.guid, sipkey, 1, 1)
      end
    end,

  },

}

