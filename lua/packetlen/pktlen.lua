--
-- pktlen.lua
--
-- 	Working sample adds a new counter group called "Packet Length"
--
TrisulPlugin = {

	id = {
		name = "Length Counter",
		description = "Counts packet lengths",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	onload = function()
		T.host:log(T.K.loglevel.INFO, 
				"OnLoad Packet Length Counter LUA plugin, Hi! ");

	end,


	onunload = function ()
		T.host:log(T.K.loglevel.INFO, 
				"OnUnload Packet Length Counter LUA plugin, bye!");
	end,


	countergroup = {

		-- control section
		--   Id of the counter group 
		control = {
			guid = "{6ecb4ebb-d53b-470c-aca6-2f326b4c6c91}",
			name = "Packet Length",
			description = "Packet length distribution",
			bucketsize = 30,
		},

		-- meter section
		-- 	What we're trying to count 
		-- 	meter 0 -  bytes by packet len
		-- 	meter 1 -  number of packets of each length 
		meters = {
				{  0, T.K.vartype.COUNTER, 10, "Bytes", "bytes" , "B" },
				{  1, T.K.vartype.COUNTER, 10, "Packets", "packets",  "Pkts" },
		},

	},


	simplecounter = {

		--
		-- we want to listen in at the IP protocol layer 
		-- see trisul.org/docs/ref/guid.html 
		--
		protocol_guid = "{0A2C724B-5B9F-4ba6-9C97-B05080558574}",

		-- onpacket
		-- 	Called each packet at IP layer 
		-- 	(see protocol_guid in control section) 
		onpacket = function(engine,layer)

			
			local packet= layer:packet()

			local len  = packet:wire_length()

			local key = ""

			if len > 1400 then key = "1400+"
			elseif len > 1000 then key = "1000-1400"
			elseif len > 500 then key = "500-1000"
			elseif len > 200 then key = "200-500"
			elseif len > 100 then key = "100-200"
			elseif len > 60 then key = "60-100"
			else key = "0-60" 
			end


			--
			-- update_counter methods is the "magic"  glue
			-- between C and LUA in trisul
			--
			engine:update_counter_bytes( 
					TrisulPlugin.countergroup.control.guid, key , 0)

			engine:update_counter( 
					TrisulPlugin.countergroup.control.guid, key, 1, 1)


		end,


	 },

}

