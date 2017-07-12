--
-- packet_storage.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Fine grained control of PCAP storage
-- DESCRIPTION: For each flow determine how you want to store packets 
--
--
-- 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "Dont store backsup",
    description = "Ignore flows to subnet 10.200 between 10PM and 1AM", -- optional
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


  -- packet_storage block;
  --
  packet_storage   = {

    -- WHEN CALLED: a new flow is first seen 
    -- specify packet (pcap)  storage policy for this flow
    -- 
    filter = function( engine, timestamp, flow ) 
      -- your lua code
      -- return a number from -1..6 representing how to handle packet storage for this flow.
      -- See docs for packet_storage for values
      return -1
    end,


    -- WHEN CALLED: the first reassembled chunk in each direction is seen
    -- use this if you need to see the actual first few bytes of the flow 
    -- before you decide you want to store the flow or not 
    filter_payload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
      -- your lua code
      -- return a number from -1..6 representing how to handle packet storage for this flow.
      -- See docs for packet_storage for values
      return -1
    end,    

  },
}
