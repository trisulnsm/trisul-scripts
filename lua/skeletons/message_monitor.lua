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


  -- messagemonitor  block
  -- 
  messagemonitor   = {


    -- when a new flow metric is seen
    -- used with TCP reassembly 
    onflowmetric  = function(engine,flowid,meter,value)

    end,

    -- when a new NetFlow record is seen
    -- use this to tap into NetFlow records and add counters within context of those records 
    onnewflowrecord = function(engine, flowid, bytes_az, bytes_za, packets_az, packets_za)

    end, 


  },
}
