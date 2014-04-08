--
-- tagclen.lua
-- 	
-- 	Tags user agent with old java verson
--
--
TrisulPlugin = {

	id = {
		name = "Tag flows ",
		description = "Tagging user agent ",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},


	flowmonitor  = {

		onflowattribute = function(engine,flow,
								   timestamp,
								   aname, avalue)

			if aname == "User-Agent" then
				if avalue:find("Mozilla/[123]") then 
					engine:tag_flow( flow:id(), "oldmoz")
				end
			end

		end,
	 },
}

