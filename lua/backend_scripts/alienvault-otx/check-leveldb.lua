-- check IOC against a levelDB database
--
-- TYPE:        BACKEND SCRIPT
-- 

local LDB=require'tris_leveldb'

TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "Intel IOC Check",
    description = "Check all items for hit in a LevelDB database ", 
  },

  onload = function()

  end,

  -- dont store the Intel harvested in backend, save space 
  resource_monitor  = {

    resource_guid = '{EE1C9F46-0542-4A7E-4C6A-55E2C4689419}', 

    onbeginflush=function(engine) 
	T.leveldb = LDB.new()
	local ok,errmsg=T.leveldb:open("/usr/local/share/trisul-probe/plugins/trisul-intel.leveldb."..engine:instanceid())
	if not ok then
		T.logerror("Unable to open the leveldb file e="..errmsg)
		T.leveldb=nil
	end 

	 
    end, 


    onendflush=function()
	if T.leveldb then T.leveldb:close() end 
    end,

	  -- 
	  -- always return false from flushfilter 
	  -- dont want to save
	  -- 
    flushfilter = function(engine, resource) 
	if not T.leveldb then return false  end

    	local hit = T.leveldb:get(resource:label())
	if hit then
	     engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}",
                 resource:flow():id(),
                 "ALIENVAULT-HIT",
                 1,
                 "Resource ".. resource:uri()..
	         " IOC "..resource:label()..
                 " hit an AlientVault OTX IOC. JSON".. hit)
	end 

	return false 
    end,

  },
}

