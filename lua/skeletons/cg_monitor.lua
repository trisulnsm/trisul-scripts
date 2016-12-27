--
--cg_monitor.lua
--
TrisulPlugin = { 

  id =  {
    name = "Host counter group Monitor",
    description = "Monitor your host counter group",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  cg_monitor  = {

    -- which alert group do you want to monitor
    -- need a separate lua file for each type of countergroup! 
    counter_guid = "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",

     ---- about to flush flow to db 
    onbeginflush = function(engine, timestamp) 
      -- your lua code goes here 
    end,

    -- flushing one item 
    onflush = function(engine, timestamp,key, metrics) 
      -- your lua code goes here 
      --
    end,

     -- end of flush
    onendflush = function(engine) 
      -- your lua code goes here 
    end,

     ---- about to flush toppers to db 
    onbegintopperflush = function(engine, timestamp, meter)
      -- your lua code goes here 
    end,

    ---- flushing one meter 
    ontopperflush = function(engine, timestamp, meter)
      -- your lua code goes here 
    end,

    --end of toppers flush
    onendtopperflush = function(engine, timestamp, meter)
      -- your lua code goes here 
    end,

    -- update a key
    onupdate = function(engine, key, timestamp, arrayofmetrics)
      -- your lua code goes here 
    end,

    --  new key
    onnewkey = function(engine, key, timestamp)
      -- your lua code goes here 
    end,

    -- every 1 sec
    onmetronome = function(engine, timestamp, tick_count, tick_interval )
      -- your lua code goes here 
    end,

  },

}