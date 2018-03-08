--
-- User-Agent 
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Nothing much , just create User-Agents as Resources 
-- DESCRIPTION: 
-- 
TrisulPlugin = { 


  -- 
  id =  {
    name = "Create UA-Resources",
    description = "use onattribute", 
  },


  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    onattribute = function(engine, timestamp, flowkey, attr_name, attr_value) 
		if attr_name == "User-Agent" then
			engine:add_resource("{ED5CA168-1E17-44E0-7ABD-65E5C2DFAD21}",
								 flowkey:id(),
								 attr_value);
		end 
    end,    

  },

}
