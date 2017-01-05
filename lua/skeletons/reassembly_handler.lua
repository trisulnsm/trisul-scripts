--
-- reassembly_handler.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Hook into Trisul's TCP reassembly engine 
-- DESCRIPTION: Handle TCP flow events and reassembled payloads using LUA
--              also hook into Trisul's detection of certain 'attributes'
--              contained in flows such as some HTTP headers, SSL Certs
--              You could of course do all of that yourself direclty by 
--              looking at the payloads. Check out the  docs for more 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "Save TCP streams",
    description = "Save reassembled TCP payloads into separate files for XYZ host",
    author = "Unleash",       -- optional field
    version_major = 1,        -- optional field
    version_minor = 0,        -- optional field 
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



  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- WHEN CALLED: a new flow is detected (eg from a SYN packet) 
    --  look at flow tuples and decide if you want to reassemble 
    --  return true : to enable reassembly , false to disable
    --  skip this function if you always want to enable 
    filter = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
      return true
    end,



    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    -- handle reassembled byte stream here , 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
      -- your lua code goes here 
    end,




    -- WHEN CALLED: a new flow is first detected 
    -- when a new flow is established 
    -- 
    onnewflow = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: a flow is terminated or timed out 
    -- 
    onterminateflow  = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: when a built in attribute of a flow is detected by Trisul
    -- onattribute - handle a flow based attribute 
    -- 
    onattribute = function(engine, timestamp, flowkey, attr_name, attr_value) 
      -- your lua code goes here 
    end,    

  },

}
