--
-- resource_monitor.lua skeleton
--
-- step3 : Loading an Intel file  in memory to be used later 
-- 
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     handle Resources extracted by Trisul 
-- DESCRIPTION: step3.lua is step2.lua PLUS 
--               + load an intel file, urlhaus blacklist into a Lua memory table 
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "STEP2",
    description = "Print HTTP URL Resources and generate alert on GIF", 
  },

  onload=function()

	-- we're going to load this table with Intel 
	local csv_path = "/tmp/urlhaus.txt" 

	T={}
	T.badurls = {} 

	-- loop every line in CSV 
	print("Processing CSV file "..csv_path) 
	local f = io.open(csv_path)
	for line in f:lines() do
		local fields={}
		for fld  in line:gmatch('"([^"]*)"') do
			fields[#fields+1]=fld
		end 
		T.badurls[fields[3]] = "lajda"
	end
	print("Loaded "..#T.badurls.." URLs from file") 

  end,


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
