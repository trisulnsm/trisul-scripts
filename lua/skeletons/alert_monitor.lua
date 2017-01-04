--
-- alert_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Listen to alert activity 
-- DESCRIPTION: Process streaming alerts as they come in and also plug into 
--              the "flush" activity when alerts are forwarded to the 
--              Hub nodes for storage. 
-- 
TrisulPlugin = { 

 -- the ID block, you can skip the fields marked 'optional '
 -- 
 id =  {
    name = "IDS alert group Monitor",
    description = "Process alert events in the IDS alert group ", -- optional
    author = "Unleash",                                           -- optional
    version_major = 1,                                            -- optional 
    version_minor = 0,                                            -- optional 
  },

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
    
  end,



  -- the alert_monitor block
  -- you only need to define the functions you need 
  alert_monitor  = {


    -- which alert group do you want to monitor
    -- each alert group is identified by a GUID login as admin > profile > Alert groups to view 
    alert_guid = '{99A78737-4B41-4387-8F31-8077DB917336}',



    -- WHEN CALLED: when a new alert is received in the backend (within 1 sec of actual reception)
    onnewalert  = function(engine, alert) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: when a FLUSH operation starts 
    -- by default called every "stream snapshot interval" of 60 seconds
    onbeginflush = function(engine) 
      -- your lua code goes here  
    end,



    -- WHEN CALLED: before an alert is flushed to the Hub node  
    onflush = function(engine, alert) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: when each alert is flushed to the hub node (default every 60 secs)
    -- return false if you dont want to save this alert, true to save 
    flushfilter = function(engine, alert) 
      -- your lua code goes here 
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
