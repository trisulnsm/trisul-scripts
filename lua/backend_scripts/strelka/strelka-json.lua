--
-- engine_monitor.lua - tail all the strelka JSON and push into Trisul using add_resource()
--
-- 
TrisulPlugin = { 

  -- id block 
  --
  id =  {
    name = "Strelka JSON",
    description = "Feedback JSON scan results back into trisul", 
  },


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


  },

}
