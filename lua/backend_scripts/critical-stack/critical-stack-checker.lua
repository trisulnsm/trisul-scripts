-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Checks harvested Indicators against a CriticalStack database 
-- 

local LDB=require'tris_leveldb'

TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "Critical-Stack check",
    description = "Check all harvested IOC in leveldb", 
  },

  onload = function()
	T.LDB = nil 
	T.permanent_error=false
  end,

  -- dont store the Intel harvested in backend, save space 
  resource_monitor  = {

    resource_guid = '{EE1C9F46-0542-4A7E-4C6A-55E2C4689419}', 

	-- 
	-- do you want to save these Harvested resources on the Hub
	-- 
    flushfilter = function(engine, resource) 

	if T.permanent_error then return false end 

	if T.LDB == nil then
		T.LDB = LDB.new()
		local compiled_db = T.env.get_config("App>DataDirectory") .. "/plugins/critical-stack.trisul." ..  engine:id() 
		local f,err= T.LDB:open( compiled_db ) 
		if not f then 
			T.logerror("Error opening critical stack LevelDB err="..err) 
			T.logerror("DB file="..compiled_db) 
			T.permanent_error=true
			return false 
		else
			T.loginfo("Opened successfully "..compiled_db)
		end 
	end 

	local match_val = T.LDB:get(resource:label())
	if match_val then 
		engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}", -- user alerts : group
				 resource:flow():id(),
				 "CRIT-STACK",
				 2,
				 match_val ) 
	end 
	return false 
    end,
  },
}

