-- .lua
--
-- cgmon.lua
-- Monitors counter group activity 
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
    print("onload :  from cgmon.lua"..T.contextid)
  end,

  onunload = function()
    print("onunload:  bye   cgmon.lua"..T.contextid)
  end,

  -- 
  -- Monitor attaches itself to a counter group and gets called for
  -- all keys matching the regex 
  --
  cg_monitor  = {

    counter_guid = "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",

    onbeginflush = function(dbengine,tvsec) 
      print(string.format("onbeginflush [%d]", T.contextid  )) 
    end,

    onflush= function(dbengine,ts,key,metrics )
      print(string.format("onflush [%d]  %s", T.contextid  , key )) 
    end,

    onendflush = function(dbengine)
      print(string.format("onendflush [%d]", T.contextid  )) 
    end,

  },

}

