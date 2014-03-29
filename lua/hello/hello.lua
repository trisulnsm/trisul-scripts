--
-- Basic working script, just prints hello
--
TrisulPlugin = {

	id = {
		name = "Hello World",
		description = "Nothing much ",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	onload = function()
		print("Onload - hello world  "); 
		T.host:log(T.K.loglevel.INFO, "Hello world now in log file ");
	end,


	onunload = function ()
		print("Onunload  - bye  ");
	end,

}

