-- 
-- hello2.lua
--     calls a bunch of methods on T.host inside onload
--
--
TrisulPlugin = {

	id = {
		name = "Hello2",
		description = "does nothing much",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	onload = function()
		print("Onload - hey "); 

		T.host:log(T.K.loglevel.INFO, 
					"OnLoad LUA plugin, Hi! ");


		-- 
		-- print home networks
		--
		local hn = T.host:get_homenets()
		print("Homenets\n");

		for i,v in pairs(hn) do
			print(T.util.ntop(v[1]).."\t"..T.util.ntop(v[2]))
		end


		--
		-- directories where trisul stores config and data 
		--
		print("config = "..T.host:get_configpath())
		print("data = "..T.host:get_datapath())


	end,


	onunload = function ()
	end,


	countergroup = {

		-- control section
		--   Id of the counter group 
		control = {
			guid = "{6ecb4ebb-d53b-470c-aca6-2f326b4c6c91}",
			protocol_guid = "{0A2C724B-5B9F-4ba6-9C97-B05080558574}",
			name = "Packet Length",
			description = "Packet length distribution",
			bucketsize = 30,
		},

		-- meter section
		-- 	What we're trying to count 
		meters = {
				{  0, T.K.vartype.COUNTER, 10, "Bytes", "bytes" , "B" },
				{  1, T.K.vartype.COUNTER, 10, "Packets", "packets",  "Pkts" },
		},

	},


	simplecounter = {


		-- onpacket
		-- 	Called each packet at IP layer (see protocol_guid in control section) 
		onpacket = function(engine,layer)


			--[[
			print("onpacket now.. packet length = "..layer:total_bytes())
			print("Hexdump\n")


			local bytes = layer:rawbytes()
			print(bytes:hexdump())

			print("ip length = "..bytes:hval_16(2))
			print("protocol  = "..bytes:hval_8(9))


			print("wire length  = "..packet:wire_length())
			print("cap  length  = "..packet:capture_length())

			local tvsec, tvusec = packet:timestamp()
			print("timestamp    = "..os.date("%c",tvsec))
			]]--

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


			engine:update_counter_bytes( TrisulPlugin.countergroup.control.guid, key , 0)

			engine:update_counter( TrisulPlugin.countergroup.control.guid, key, 1, 1)


		end,


	 },

}

