--
-- ua-resource-monitor 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     User-Agent parser 
-- DESCRIPTION: Uses Regex User Agent parser ua-parser  
--              https://github.com/ua-parser/uap-core 
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "User-Agent Parser ",
    description = "Extract Browser,Device,OS", 
  },


  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
    -- your code 
  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    -- your code 
  end,


  -- resource_monitor block 
  --
  resource_monitor  = {

    -- listen to User-Agent resource 
    resource_guid = '{ED5CA168-1E17-44E0-7ABD-65E5C2DFAD21}',


    -- Each user-agent resource is flushed, use the Regexes to process 
    onflush = function(engine, resource) 
		print(resource:uri())
    end,

  },

}
