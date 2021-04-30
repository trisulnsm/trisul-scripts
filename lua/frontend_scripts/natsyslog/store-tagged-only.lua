--
-- only store tagged flows 
-- 
TrisulPlugin = { 

  id =  {
    name = "Only tagged flows ",
    description = "Monitor IP flows and generated further metrics ",
  },


  -- sg_monitor block
  sg_monitor  = {

    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}', -- optional

	-- only store flows with tag 
    flushfilter = function(engine, flow) 
		local t = flow:tags()

		if #t > 0 then
			return true
		else
			return false
		end 
    end,

  },
}

