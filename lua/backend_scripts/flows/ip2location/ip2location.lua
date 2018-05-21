-- ip2location.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Consumes the ip2location CSV databases and enriches ASN,Country,Region,Proxy 
-- DESCRIPTION: Four new counter groups & edges 
-- 
-- 
local leveldb=require'tris_leveldb' 
local bit=require'bit'
local dbg=require'debugger'

TrisulPlugin = { 

  id =  {
    name = "IP2Location",
    description = "Uses IP2Location databases to enrich and meter Geo metrics to Trisul", 
  },

  onload = function() 
  	T.ldb_loadtm=0
  	T.ldb_iterator=nil
  	T.ldb=nil 
	T.permanent_failure=false 
  end,

  onunload=function()
  	if T.ldb_iterator then T.ldb_iterator:destroy()  end 
  	if T.ldb then T.ldb:close()  end 
  end,

  reload=function()
	print("LevelDB directory modification detected, reloading from "..T.ldb_path)
  	TrisulPlugin.onunload() 
	T.ldb = leveldb.new()
	local f,err=T.ldb:open(T.ldb_path, true)
	if not f then 
		print("Unable to find source LevelDB database "..T.ldb_path)
		T.ldb=nil
		return 
	end
	T.ldb_iterator=T.ldb:create_iterator()
  end,

  lookup_prefix = function(iter,prefix,key)
	local k0,v0= T.ldb:upper(T.ldb_iterator, prefix..key)
	if k0 then 
		local k1,k2 = k0:match("%u+:([%x%.]+)-([%x%.]+)")
		if key < k1 and key > k2 then
			return v0
		end
	end
  end,


  -- 
  -- sg_monitor block
  sg_monitor  = {

	-- reload if levelDB has a new modificationtime 
	-- 
    onbeginflush = function(engine)
		T.ldb_path = "/tmp/trisul-ip2loc.level_"..engine:id()

		if T.ldb then 
			local mtime = tonumber(T.ldb:getval("last_updated_tm"))
			if mtime > T.ldb_loadtm then
				TrisulPlugin.reload()
				T.ldb_loadtm=mtime
			end
		else 
			TrisulPlugin.reload()
			T.ldb_loadtm=tonumber(T.ldb:getval("last_updated_tm"))
		end 

		T.key_labels_added = { } 
	end,

	-- do the metering for IP endpoints  
	--
    onflush = function(engine, flow) 

		if not T.ldb then return end 

		-- 
		-- homenetworks not considered for Geo
		--
		local ip=flow:flow():ipz_readable()
		if T.host:is_homenet(ip) then 
			ip=flow:flow():ipa()
	 	end 	


		local val = TrisulPlugin.lookup_prefix(T.ldb_iterator, "ASN:",ip)
		if val then 
			local key,label = val:match("(%d+)%s*(.*)")
			TrisulPlugin.update_metrics(engine, flow, "{EF44F11F-B90B-4B24-A9F5-86482C51D125}",  key, label) 
		end 

		local val = TrisulPlugin.lookup_prefix(T.ldb_iterator, "CTRY:",ip)
		if val then 
			local key,label = val:match("(%s+)%s*(.*)")
			TrisulPlugin.update_metrics(engine, flow, "{F962527D-985D-42FD-91D5-DA39F4D2A222}",  key, label) 
		end

		local val = TrisulPlugin.lookup_prefix(T.ldb_iterator, "CITY:",ip)
		if val then 
			local key,label = val:match("(%s+)%s*(.*)")
			TrisulPlugin.update_metrics(engine, flow, "{E85FEB77-942C-411D-DF12-5DFCFCF2B932}",  key, label) 
		end

		local val = TrisulPlugin.lookup_prefix(T.ldb_iterator, "PROXY:",ip)
		if val then 
			local key,label = val:match("(%s+)%s*(.*)")
			TrisulPlugin.update_metrics(engine, flow, "{2DCA13EB-0EB3-46F6-CAA2-9989EA904051}",  key, label) 
		end

    end,

  },


	-- metrics updated
	update_metrics=function(engine, flow, guid, key, label) 

		local dir=0
		if T.host:is_homenet(flow:flow():ipz_readable()) then 
			dir=1
		end 

		engine:update_counter( guid,  key, 0, flow:az_bytes()+flow:za_bytes());
		if dir==0 then 
			engine:update_counter ( guid ,  key, 1, flow:az_bytes())
			engine:update_counter ( guid ,  key, 2, flow:za_bytes())
		else 
			engine:update_counter ( guid ,  key, 2, flow:az_bytes())
			engine:update_counter ( guid ,  key, 1, flow:za_bytes())
		end

		if label and not T.key_labels_added[key] then 
			engine:update_key_info (guid ,  key, label) 
			T.key_labels_added[key]=true 
		end

		engine:add_flow_edges(flow:key(), guid, key) 

	end 
}
