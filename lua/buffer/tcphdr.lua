--
-- tcphdr.lua
--
-- 	Prints the TCP header  - does not actually meter anything 
--
-- 	Demonstrates how you can work with 
-- 	 1) The Buffer object
-- 	 2) The Layer
-- 	 3) The Packet 
--
TrisulPlugin = {

	id = {
		name = "TCPHDR ",
		description = "Demo - prints tcp header ",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	simplecounter = {

		protocol_guid = "{77E462AB-2E42-42ec-9A58-C1A6821D6B31}",

		-- onpacket
		onpacket = function(engine,layer)

			local buff = layer:rawbytes() 

			-- T.debugger({ engine = engine, layer = layer })
			--
			
			print("Source port = " .. buff:hval_16(0))
			print("Dest port   = " .. buff:hval_16(2))
			print("Seq number  = " .. buff:hval_32(4))
			print("Ack number  = " .. buff:hval_32(8))



		end,


	 },


}
