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


}

