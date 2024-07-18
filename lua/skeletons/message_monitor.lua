--
-- message_monitor.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     message monitor 
-- DESCRIPTION: MMON listens to TMS frontend messages 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "MessageMonitor",
    description = "mmonitor listens to messages ", 
  },


  -- messagemonitor  block
  -- 
  messagemonitor   = {

  onflowmetric  = function(engine,flowid,meter,value)

  end,

  },
}
