--
-- resource_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     handle Resources extracted by Trisul 
-- DESCRIPTION: Trisul platform extracts resources (files,hashes,dns,ssl certs, etc)
--              they stream through the backend pipeline. Here is where you handle them
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "DNS Monitor",
    description = "Do stuff with DNS resources", 
    author = "Unleash",                       -- optional
    version_major = 1,                        -- optional
    version_minor = 0,                        -- optional
  },



  -- common functions onload, onunload, onmessage()..

  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
    -- your code 
  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    -- your code 
  end,

  -- any messages you want to handle for state management 
  message_subscriptions = {},

  -- WHEN CALLED: when another plugin sends you a message 
  onmessage = function(msgid, msg)
    -- your code 
  end,




  -- resource_monitor block 
  --
  resource_monitor  = {

    -- which resource group do you want to monitor
    -- the following GUID represents DNS resources, Login as admin > Profiles> Resource Groups
    -- to see list of resources 
    resource_guid = '{D1E27FF0-6D66-4E57-BB91-99F76BB2143E}',

    -- WHEN CALLED : a new resource is seen (immediately)
    onnewresource  = function(engine, resource )
      -- your lua code goes here 
    end,


    -- WHEN CALLED: when a FLUSH operation starts 
    -- by default called every "stream snapshot interval" of 60 seconds
    onbeginflush = function(engine) 
      -- your lua code goes here  
    end,



    -- WHEN CALLED: before a resource is flushed to the Hub node  
    onflush = function(engine, resource) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: when each resource is flushed to the hub node (default every 60 secs)
    -- return false if you dont want to save this resource, true to save 
    flushfilter = function(engine, resource) 
      -- your lua code goes here 
      return true
    end,



    -- WHEN CALLED: end of flush
    onendflush = function(engine) 
      -- your lua code goes here 
    end,

    -- WHEN CALLED: every 1 sec
    onmetronome = function(engine, timestamp, tick_count, tick_interval )
      -- your lua code goes here 
    end,
  },

}