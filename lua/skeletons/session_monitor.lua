--
-- session_group_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     session (flow) updates. IP flows are a type of sesssion group 
-- DESCRIPTION: Handle flow related streaming metrics and listen to flows as they
--              are flushed to the database (hub) node. 
-- 
TrisulPlugin = { 

  id =  {
    name = "My IP Flow Monitor",
    description = "Monitor IP flows and generated further metrics ",
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




  -- sg_monitor block
  -- sg = session group
  sg_monitor  = {

    -- that guid refers to IPv4/IPv6 flows (you can skip the session_guid field if you want its the default )
    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}', -- optional

    -- WHEN CALLED: a new flow is seen 
    onnewflow  = function(engine, flow ) 
      -- your lua code goes here 
    end,

    -- WHEN CALLED: new metrics on existing flow 
    -- Note: High frequency function, ensure this method is fast and does not do I/O 
    onupdate = function(engine, flow) 
     -- your lua code goes here 
    end,

    -- WHEN CALLED: a flow was terminated 
    onterminate = function(engine, flow) 
      -- your lua code goes here 
    end,


    -- WHEN CALLED: when a flow FLUSH operation starts 
    -- by default called every "stream snapshot interval" of 60 seconds
    onbeginflush = function(engine) 
      -- your lua code goes here  
    end,

    -- WHEN CALLED: before a flow is flushed to the Hub node  
    onflush = function(engine, flow) 
      -- your lua code goes here 
    end,

    -- WHEN CALLED: when each flow is flushed to the hub node (default every 60 secs)
    -- return false if you dont want to save this flow, true to save 
    flushfilter = function(engine, flow) 
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
