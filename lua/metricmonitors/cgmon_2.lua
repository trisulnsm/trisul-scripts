-- .lua
--
-- cgmon2.lua
-- Monitors counter group activity  - demonstrates the update(..) method
--
--
TrisulPlugin = {

  id = {
    name = "CG Monitor ",
    description = "Example of monitoring counter group activity ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  onload = function()
  end,

  onunload = function()
  end,

  -- 
  -- Monitor attaches itself to a counter group and gets called for
  -- all keys matching the regex 
  --
  cg_monitor  = {

    counter_guid = "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",

	onupdate = function(dbengine,key,tvsec,metrics) 
	   print(string.format("onupdate  [%d]   %d  %10s %s", T.contextid, tvsec, key, table.concat(metrics,' ')  )) 
	end,

  },

}

