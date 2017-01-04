--
--session_group.lua
--
--

TrisulPlugin = { 

  id =  {
    name = "Session group Monitor",
    description = "Monitor your sessions",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  sg_monitor  = {
    -- that guid refers to IPv4/IPv6 flows 
    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}',

    -- a new flow is started
    onnewflow  = function(engine, flow ) 
      -- your lua code goes here 
    end,

    -- new metrics on existing flow 
    onupdate = function(engine, flow) 
     -- your lua code goes here 
    end,

    -- terminated 
    onterminate = function(engine, flow) 
      -- your lua code goes here 
    end,

    -- return false if you dont want to save in DB
    flushfilter = function(engine, flow) 
      -- your lua code goes here 
    end,

    -- about to flush flow to db 
    onbeginflush = function(engine) 
      -- your lua code goes here 
    end,

    -- flushing one flow 
    onflush = function(engine, flow) 
      -- your lua code goes here 
    end,

    -- end of flush
    onendflush = function(engine) 
      -- your lua code goes here 
    end,

    -- every 1 sec
    onmetronome = function(engine, timestamp, tick_count, tick_interval)
      -- your lua code goes here
    end,
  },

}
