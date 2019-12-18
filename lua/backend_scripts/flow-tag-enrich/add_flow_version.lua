--
-- session_group_monitor.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     session (flow) updates. IP flows are a type of sesssion group 
-- DESCRIPTION: Handle flow related streaming metrics and listen to flows as they
--              are flushed to the database (hub) node. 
-- 
TrisulPlugin = { 

  id =  {
    name = "Add Version to Flow",
    description = "Add tag IPv6 or IPv4 flows",
  },


  -- sg_monitor block
  -- sg = session group
  sg_monitor  = {

    -- that guid refers to IPv4/IPv6 flows (you can skip the session_guid field if you want its the default )
    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}', -- optional

    -- WHEN CALLED: before a flow is flushed to the Hub node  
    onflush = function(engine, flow) 
		if flow:flow():ipa():len()==32 then
			flow:add_tag("[ipver]6")
		else
			flow:add_tag("[ipver]4")
		end
    end,

  },

}
