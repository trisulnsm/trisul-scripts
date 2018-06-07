--
-- resource_monitor.lua skeleton
--
-- step1 : Just prints  URL Resources 
-- 
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     handle Resources extracted by Trisul 
-- DESCRIPTION: Trisul platform extracts resources (files,hashes,dns,ssl certs, etc)
--              they stream through the backend pipeline. Here is where you handle them
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "STEP1",
    description = "Print HTTP URL Resources", 
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
    	
    end,

    }


}
