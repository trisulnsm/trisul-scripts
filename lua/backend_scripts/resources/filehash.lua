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

		-- 
		-- The guid {978.. below represents the File Hashes resource
		-- Login as admin/admin , then context0 > Resource Groups to view list of 
		-- installed resource GUIDs
		--
	  resource_guid = '{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}',

		onnewresource  = function(engine, newresource )
			print("timestamp "..  os.date('%c',newresource:timestamp()))
			print("hash = ".. newresource:uri())
			print("label  = ".. newresource:label())
			print("flow  = ".. newresource:flow():to_s())
		end,

	},

}
