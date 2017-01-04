--
--resource_group.monitor
-- 
TrisulPlugin = { 

  id =  {
    name = "Resource group  Monitor",
    description = "Monitor your DNS respurces",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },
  resource_monitor  = {

    -- which resource group do you want to monitor
    -- need a separate lua file for each type of resource ! 
    resource_guid = '{D1E27FF0-6D66-4E57-BB91-99F76BB2143E}',

    -- a new resource is started
    onnewresource  = function(engine, resource )
      -- your lua code goes here 
    end,

    --- on begin flush
    onbeginflush = function(engine)
      -- your lua code goes here 
    end,

     -- return false if you dont want to save in DB
    flushfilter = function(engine, resource)
      -- your lua code goes here 
    end,

    -- flushing one resource 
    onflush = function(engine, resource)
      -- your lua code goes here 
    end,

    -- end of flush
    onendflush = function(engine)
      -- your lua code goes here 
    end,
  },

}