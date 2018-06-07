--
-- resource_monitor.lua skeleton
--
-- step2 : Shows how to generate an ALERT, here we gen alert if we find a string "gif" in URL  
-- 
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     handle Resources extracted by Trisul 
-- DESCRIPTION: step2.lua is step1.lua PLUS generate an alert when you find a 'gif'  in file name
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "STEP2",
    description = "Print HTTP URL Resources and generate alert on GIF", 
  },


  -- resource_monitor block 
  --
  resource_monitor  = {

    -- which resource group do you want to monitor
    -- the following GUID represents HTTP URL resources, 
    -- to see list of Resource GUIDs 
    -- https://www.trisul.org/docs/ref/guid.html#resource_groups
    -- or Login as admin : view resources
    -- 
    resource_guid = '{4EF9DEB9-4332-4867-A667-6A30C5900E9E}',

    -- WHEN CALLED : a new resource is seen (immediately)
    -- the resource is a LUA Object 
    -- see https://www.trisul.org/docs/lua/resource_monitor.html#resource
    onnewresource  = function(engine, resource )

    	-- print(resource:uri())

	if resource:uri():find("gif") then

		-- add an alert to Trisul 
		-- we use General Purpose Alert Group identified by the GUID
		-- see https://www.trisul.org/docs/ref/guid.html#alert_groups 
		-- 
		-- add_alert is a method you call on Trisul Engine to push an alert
		-- into the trisul pipelines, see https://www.trisul.org/docs/lua/obj_engine.html#function_add_alert
		engine:add_alert( 
			"{B5F1DECB-51D5-4395-B71B-6FA730B772D9}",         -- type 
			resource:flow():id(),				  -- flow ID
			"MY-URL-HAUS",                                    -- alert type to distinguish from other User Alerts
			3,						  -- priority 3 
			"Hey I found a gif resource".. resource:uri())    -- a message 

	end 
    	
    end,

    }


}
