--
-- fts_monitor.lua
--
TrisulPlugin = { 
  
  id =  {
    name = "FTS  Monitor",
    description = "Monitor your fts HTTP Headers",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },
  fts_monitor  = {

    -- which FTS group do you want to monitor
    -- need a separate lua file for each type of FTS ! 
    fts_guid = '{28217924-E7A5-4523-993C-44B52758D5A8}',

    -- a new FTS is started
    onnewfts  = function(engine, fts )
      -- your lua code goes here 
    end,

    ---- about to flush flow to db 
    onbeginflush = function(engine)
      -- your lua code goes here 
    end,
     -- return false if you dont want to save in DB
    flushfilter = function(engine, fts)
      -- your lua code goes here 
    end,
    
    -- flushing one FTS 
    onflush = function(engine, fts)
      -- your lua code goes here 
    end,

     -- end of flush
    onendflush = function(engine)
      -- your lua code goes here 
    end,
  },
}