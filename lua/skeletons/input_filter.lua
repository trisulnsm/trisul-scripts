--
-- input_filter.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Input filter to drive the Trisul pipeline 
-- DESCRIPTION: Custom input for packets, flows, or alerts
--
--
-- 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "CSV netflow input",
    description = "read flow records from CSV", -- optional
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




  -- input_filter block
  -- 
  inputfilter = {



    -- WHEN CALLED: when Trisul platform wants a new packet or flow 
    -- step block : to handle packets and flows
    -- read the next line from the file and do engine:updateXXX(..) to add metrics 
    step  = function(packet, engine)
      -- your lua code here 
    end,



    -- WHEN CALLED: when Trisul platform wants a new packet or flows 
    -- step_alert block : to feed alerts into the pipeline 
    --   need to return a table { } with alert information; see the docs 
    step_alert  = function() 
      -- your lua code here
    -- return a table { }

    end,
   


  },
}
