---
-- engine monitor
-- 
TrisulPlugin = { 

  id =  {
    name = "Engine  Monitor",
    description = "Monitor the backend engine events.",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },
  engine_monitor  = {

    ---- about to flush flow to db 
    onbeginflush  = function(engine, timestamp )
      -- your lua code goes here 
    end,

    --end of flush
    onendflush  = function(engine, timestamp )
      -- your lua code goes here 
    end,

    -- every 1 sec
    onmetronome  = function(engine, timestamp, tick_count, tick_interval  )
      -- your lua code goes here 
    end,

  },

}