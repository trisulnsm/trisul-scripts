--
-- alertgroup_monitor.lua
-- 
--
TrisulPlugin = { 


 id =  {
    name = "IDS alert group Monitor",
    description = "Monitor your IDS alert group",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  alert_monitor  = {

    -- which alert group do you want to monitor
    -- need a separate lua file for each type of alert ! 
    alert_guid = '{99A78737-4B41-4387-8F31-8077DB917336}',

    -- a new alert is started
    onnewalert  = function(engine, alert) 
      -- your lua code goes here 
    end,

     -- return false if you dont want to save in DB
    flushfilter = function(engine, alert) 
      -- your lua code goes here 
    end,

    -- about to flush alert to db 
    onbeginflush = function(engine) 
      -- your lua code goes here  
    end,

    -- flushing one alert 
    onflush = function(engine, alert) 
      -- your lua code goes here 
    end,

    -- end of flush
    onendflush = function(engine) 
      -- your lua code goes here 
    end,
  },

}