--
-- cg_monitor_2.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Process metrics as they are streamed and snapshotted 
-- DESCRIPTION: Monitor multiple counter groups by passing an array of GUIDs
-- 
-- This version binds to multiple counter groups via counter_guid = { ... }
-- 
TrisulPlugin = { 

  -- id block 
  id =  {
    name = "Multi CG Listener",
    description = "Listen and process events in 'Hosts' counter group",   -- optional
    author = "Unleash",                       -- optional
    version_major = 1,                        -- optional
    version_minor = 0,                        -- optional
  },

  -- 
  -- common functions onload, onunload, onmessage()..

  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
    print("onload: cg_monitor_2.lua context=" .. T.monitor_group_name.. " guid="..T.monitor_group_guid)
  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    -- your code 
    print("UNLOAD: cg_monitor_3.lua context=" .. T.monitor_group_name.. " guid="..T.monitor_group_guid)

  end,

  -- any messages you want to handle for state management 
  message_subscriptions = {},

  -- WHEN CALLED: when another plugin sends you a message 
  onmessage = function(msgid, msg)
    
  end,



  -- cg_monitor block
  -- 
  cg_monitor  = {

    -- bind to multiple counter groups (array of GUIDs)
    -- {4CD..} = Hosts, {4B0..} = MAC, {C51..} = Internal Hosts
    counter_guid = {
      "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",
      "{4B09BD22-3B99-40FC-8215-94A430EA0A35}",
      "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",
    },


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
	return true
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
