--
-- fts_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Full text search documents streaming
-- DESCRIPTION: Trisul extracts certain FTS docs (HTTP Headers, TLS Certs, DNS dig format records)
--              Plug in to that stream here 
-- 
TrisulPlugin = { 
  

  -- id block
  -- 
  id =  {
    name = "HTTP Header Monitor",
    description = "Monitor your fts HTTP Headers and do xyz",
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



  -- fts_monitor block
  --
  fts_monitor  = {

    -- which FTS group do you want to monitor
    -- need a separate lua file for each type of FTS ! 
    -- the following GUID refers to HTTP Headers FTS, as admin go to Profile>FTS Groups to see name->Guid
    fts_guid = '{28217924-E7A5-4523-993C-44B52758D5A8}',

    -- WHEN CALLED : a new FTS Document is seen
    onnewfts  = function(engine, fts )
      -- your lua code goes here 
    end,

    -- WHEN CALLED: when a FLUSH operation starts 
    -- by default called every "stream snapshot interval" of 60 seconds
    onbeginflush = function(engine) 
      -- your lua code goes here  
    end,



    -- WHEN CALLED: before a FTS document is flushed to the Hub node  
    onflush = function(engine, fts) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: when each FTS document is flushed to the hub node (default every 60 secs)
    -- return false if you dont want to save this fts document, true to save 
    flushfilter = function(engine, fts) 
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