--
-- counter_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Process metrics as they are streamed and snapshotted 
-- DESCRIPTION: If you are working off metrics streams, this is the script for you
-- 
-- 
-- 
TrisulPlugin = { 

  -- id block 
  id =  {
    name = "My Hosts Monitor",
    description = "Listen and process events in 'Hosts' counter group",   -- optional
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



  -- cg_monitor block
  -- 
  cg_monitor  = {

    -- which counter group do you want to monitor
    -- need a separate lua file for each type of countergroup! 
    -- the GUID {4CD..} below represents the Hosts counter group
    -- 
    counter_guid = "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",




    -- WHEN CALLED: when a FLUSH operation starts 
    -- by default called every "stream snapshot interval" of 60 seconds
    onbeginflush = function(engine, timestamp) 
      -- your lua code goes here 
    end,

    -- WHEN CALLED: before an item  is flushed to the Hub node  
    onflush = function(engine, timestamp,key, metrics) 
      -- your lua code goes here 
      --
    end,

    -- WHEN CALLED: end of flush
    onendflush = function(engine) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: when a TOPPER FLUSH operation starts 
    -- about to flush toppers to db 
    onbegintopperflush = function(engine, timestamp, meter)
      -- your lua code goes here 
    end,

    -- WHEN CALLED:  flushing one topper item  
    ontopperflush = function(engine, timestamp, meter)
      -- your lua code goes here 
    end,

    -- WHEN CALLED: end of toppers flush
    onendtopperflush = function(engine, timestamp, meter)
      -- your lua code goes here 
    end,




    -- WHEN CALLED: A metric is updated (streaming)
    -- note this can be high volume,
    onupdate = function(engine, timestamp, key, arrayofmetrics)
      -- your lua code goes here 
    end,



    --  WHEN CALLED: A new key was detected that wasnt seen in "recent" past
    -- 
    onnewkey = function(engine, timestamp, key)
      -- your lua code goes here 
    end,



    -- WHEN CALLED: every 1 sec
    onmetronome = function(engine, timestamp, tick_count, tick_interval )
      -- your lua code goes here 
    end,

  },

}