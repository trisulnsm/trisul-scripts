--
-- new_resource_group.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Create a new resource group
-- DESCRIPTION: You can create your own resource groups for your specific case 
--
--
-- 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "SHA256 Hashes",
    description = "logs SHA hash  Resources ", -- optional
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


  -- resourcegroup  block
  -- 
  resourcegroup  = {

    -- table control 
    -- WHEN CALLED: specify details of your new resource  group
    --              you can use 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{a973e25d-4434-4f0a-9656-9d2c0247eaf8}",
      name = "SHA256 file hashes",
      description = "File hash resources ",
    },

  },
}
