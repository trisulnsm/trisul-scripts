--
-- new_alert_group.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Create a new alert group
-- DESCRIPTION: You can create your own alert groups for your specific case 
--
--
-- 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "My IOC hits",
    description = "Alerts when my private IOCs match  ", -- optional
    author = "Unleash", -- optional
    version_major = 1, -- optional
    version_minor = 0, -- optional
  },

  -- COMMON FUNCTIONS:  onload, onunload, onmessage 
  -- 
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
    
  end,


  -- alertgroup  block
  -- 
  alertgroup  = {

    -- table control 
    -- WHEN CALLED: specify details of your new alert  group
    --              you can use 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{a973e25d-4434-4f0a-9656-9d2c0247eaf8}",
      name = "My IOC Hit",
      description = "When my IOC hits ",
    },

  },
}
