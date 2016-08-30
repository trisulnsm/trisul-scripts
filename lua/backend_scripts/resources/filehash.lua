-- filehash.lua
--
-- Sample skeleton script for monitoring resources 

-- 1.  Attaches to the "File Hash" resource group identified 
--     by the GUID {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}
-- 
-- 2.  Prints all the hashes seen - field resource:uri() 
--
-- 

TrisulPlugin = {

	id =  {
		name = "Prints File Hashes seen ",
		description = "Sample script that just prints new file hashes as they are seen ",
	},


	resource_monitor   = {

	    resource_guid = '{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}',

		onnewresource  = function(engine, newresource )
			print(newresource:uri())
		end,

	},

}
