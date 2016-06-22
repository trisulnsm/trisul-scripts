TrisulPlugin = {

	id =  {
		name = "sess group mon - print flows 1",
		description = "prints each invocation of onnewflow Minimal version prints flow id",
	},


	sg_monitor  = {

	    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}',

		onnewflow = function(engine, newflow)
			print( newflow:flow():id())
		end,


	},

}
