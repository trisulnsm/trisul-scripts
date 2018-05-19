--
-- ip2location.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Consumes the ip2location CSV databases and enriches ASN,Country,Region,Proxy 
-- DESCRIPTION: 
-- 


local leveldb=require'tris_leveldb2' 
local bit=require'bit'
--local dbg=require'debugger'

TrisulPlugin = { 

  id =  {
    name = "IP2Location",
    description = "Uses IP2Location databases to enrich and meter Geo metrics to Trisul", 
  },

  onload = function() 
  	T.ldb_loadtm=0
  	T.ldb_iterator=nil
  	T.ldb=nil 
  end,

  onunload=function()
  	if T.ldb_iterator then T.ldb_iterator:destroy()  end 
  	if T.ldb then T.ldb:close()  end 
  end,

  reload=function()
	print("LevelDB directory modification detected, reloading from "..T.ldb_path)
  	TrisulPlugin.onunload() 
	T.ldb = leveldb.new()
	local f,err=T.ldb:open(T.ldb_path)
	if not f then 
		print("Unable to find source LevelDB database "..T.ldb_path)
	end
	T.ldb_iterator=T.ldb:create_iterator()
  end,

  lookup_asn = function(iter,prefix,key)
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
	end,

	-- do the metering for IP endpoints  
	--
    onflush = function(engine, flow) 

		local ipa=flow:flow():ipz()
		local ipz=flow:flow():ipz()


		local val = TrisulPlugin.lookup_asn(T.ldb_iterator, "ASN:",ipa)
		if val then print("ASN "..ipa.."="..val) end 

		local val = TrisulPlugin.lookup_asn(T.ldb_iterator, "CTRY:",ipa)
		if val then print("CTRY "..ipa.."="..val) end 

		local val = TrisulPlugin.lookup_asn(T.ldb_iterator, "STAT:",ipa)
		if val then print("STAT "..ipa.."="..val) end 

		local val = TrisulPlugin.lookup_asn(T.ldb_iterator, "CITY:",ipa)
		if val then print("CITY "..ipa.."="..val) end 
    end,

  },

}
