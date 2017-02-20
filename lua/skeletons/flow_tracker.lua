--
-- flow_tracker.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     custom flow tracking 
-- DESCRIPTION: Register a new flow tracker and specify the rules and metrics 
--              
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "Flow Tracker 1",
    description = "Interesting flows for my-rules ", 
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




  -- flowtracker block 
  --
  flowtracker  = {

    -- table control
    -- WHEN CALLED: specify details of your new flow tracker
    --
    control = {
      name = "My Flows UDP on subnet X",
      description = "Only tracks flows matching blah.. ",
      bucketsize = 300, -- streaming window of 300 seconds
      count = 200,      -- track 200 top-K per window 
    },

    -- WHEN CALLED: when a FLUSH operation starts 
    -- by default called every "stream snapshot interval" of 60 seconds
    onbeginflush = function(engine) 
      -- your lua code goes here  
    end,


    -- WHEN CALLED: called for EACH flow after completion or periodically for LONG running flows
    -- return 
    --    0 : not interested in this flow (maybe uninteresting IP, port, etc)
    --    m : a number M that is the metric used in the Top-K for this flow tracker (eg, total volume )
    --
    getmetric = function(engine, flow) 
    
      -- your lua code goes here 

      return 0
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