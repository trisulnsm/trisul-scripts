-- flow-attributes.lus
-- 
-- 	Prints HTTP Hosts - a flow attribute discovered by the Trisul Reassembly Pipeline 
-- 
--
TrisulPlugin = {


	id =  {

		name = "flowattrib",
		description = "prints HTTP Host attributes ",
	},

	onload = function()


	end,


	reassembly_handler  = {



		-- Attributes are discovered by Trisul Reassembly, you can 
		-- see entire list of attributes in the LUA Docs. Here we 
		-- just print the HTTP-Host values 

		onattribute  = function(engine, time, flow, attr_type, attr_value )

			if attr_type == "Host" then
				print("Attribute "..attr_type.." = "..attr_value)
			end
		  end,
	},

}
