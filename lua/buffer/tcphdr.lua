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
                        local fval= buff:hval_16(12)

			-- how to extract a single bit 
			print("RST flag    = " .. bit32.extract(fval,2))

			-- print all the flags 
                        print("flags")
                        local t={[8]="Nonce",[7]="CWR",[6]="ECN-Echo",[5]="Urgent",[4]="Acknowledgement",[3]="Push",[2]="Reset",[1]="Syn",[0]="Fin"}
                        for k,v in pairs(t) do 
				local bit_state =  bit32.extract(fval,k)==0 and "(0) Not Set" or "(1) Set"
                        	print("\t"..v..":"..bit_state)
                        end
                        print(string.rep("_",100))


		end,


	 },


}

