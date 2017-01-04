--
-- engine_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     backend flush events 
-- DESCRIPTION: plug into this for backend flush events (default per minute )
--              After the engine monitor flush is started, each counter, alert,
--              resources group flush operations are performed one after the other. 
-- 
TrisulPlugin = { 

  -- id block 
  --
  id =  {
    name = "SNMP metrics",
    description = "Poll SNMP during begin flush and feedback into Trisul", 
    author = "Unleash",                       -- optional
    version_major = 1,                        -- optional
    version_minor = 0,                        -- optional
  },

  -- 
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
    
  end,


  -- engine_monitor block
  --
  engine_monitor  = {

    -- WHEN CALLED: before starting a streaming flush operation 
    -- called by default every 60 seconds per engine (default 2 engines)
    -- use engine:instanceid() to get the engine id 
    -- 
    onbeginflush  = function(engine, timestamp )
      -- your lua code goes here 
    end,



    -- WHEN CALLED: end of flush
    onendflush  = function(engine, timestamp )
      -- your lua code goes here 
    end,



    -- WHEN CALLED: every 1 sec
    onmetronome  = function(engine, timestamp, tick_count, tick_interval  )
      -- your lua code goes here 
    end,

  },

}