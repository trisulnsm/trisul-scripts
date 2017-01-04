--
-- reassembly_handler.lua
--  
--
TrisulPlugin = { 

  id =  {
    name = "TCP Reassembly",
    description = "Control what flows need reassembly",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  reassembly_handler   = {

    -- look at flow tuples and decide if you want to reassemble 
    -- 
    filter = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,

    -- handle reassembled byte stream here 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
      -- your lua code goes here 
    end,

    -- when a new flow is established 
    -- 
    onnewflow = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,

    -- when a flow is terminated
    -- 
    onterminateflow  = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,

    -- onattribute - handle a flow based attribute Trisul core found  
    -- 
    onattribute = function(engine, timestamp, flowkey, attr_name, attr_value) 
      -- your lua code goes here 
    end,    

  },

}