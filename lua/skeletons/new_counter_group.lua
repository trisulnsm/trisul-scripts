--
-- new_counter_group.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Create a new counter group
-- DESCRIPTION: Use this to create your own Metrics counter group with associated
--              meters and key mappings 
--
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "Packet Length",
    description = "Meter packet lengths ", -- optional
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


  -- countergroup block
  -- 
  countergroup = {

    -- control table 
	-- specify details of your new counter group you can use 
	-- 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{a973e25d-4434-4f0a-9656-9d2c0247eaf8}",
      name = "Host TCP",
      description = "Count volume and  TCP flags in all packets",
      bucketsize = 60,
    },

    -- meters table
    -- id, type of meter, toppers to track, bottom-ers to track, Name, units, units-short 
    -- 
    meters = {
        {  0, T.K.vartype.RATE_COUNTER, 10, 0, "Packets", "bytes",    "Bps" },
        {  1, T.K.vartype.COUNTER,      10, 0, "Resets",  "packets",  "Pkts" },
    },  

    -- key mapping
    -- maps keys used by you into user friendly names for Trisul display 
    keyinfo = {
      {"0-100","small pkt"},
      {"101-500","medium pkt"},
      {"501-1500","large pkt"},
      {"1501+","jumbo frame"},
    }

  },
}
