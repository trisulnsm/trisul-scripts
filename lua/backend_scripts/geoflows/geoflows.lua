-- ip2location.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Consumes the ip2location CSV databases and enriches ASN,Country,Region,Proxy 
-- DESCRIPTION: Four new counter groups & edges 
-- 
-- 
local FT=require'ftrie'

TrisulPlugin = { 

  id =  {
    name = "GeoFlows",
    description = "Use Geo intel to meter flow counts", 
  },

  onload = function() 

    -- required 
    T.ldb_root = T.env.get_config("App>DataDirectory") .. "/plugins"

    T.ldb_country=  FT.new()
    T.ldb_country:open(T.ldb_root.. "/incoming_0_GeoLite2-Country-Blocks-IPv4.csv")
    T.loginfo("Loaded Geo Country into FTRIE ")

    T.ldb_city=     FT.new()
    T.ldb_city:open(T.ldb_root.. "/incoming_0_GeoLite2-City-Blocks-IPv4.csv")
    T.key_labels_added = { } 

    T.loginfo("Loaded Geo City into FTRIE")
  end,

  onunload=function()
	T.ldb_country:close()  
	T.ldb_city:close()  
  end,


  -- 
  -- sg_monitor block
  sg_monitor  = {


	-- do the metering for IP endpoints  
	--
    onflush = function(engine, flow) 

		-- 
		-- homenetworks not considered for Geo
		--
		local ip =nil
		local iphome_readable =nil
		local f= flow:flow()
		if not T.host:is_homenet_key(f:ipa()) then 
			ip=f:ipa()
			iphome_readable=f:ipz_readable()
		elseif not T.host:is_homenet_key(f:ipz()) then 
			ip=f:ipz()
			iphome_readable=f:ipa_readable()
		else
			return
	 	end 	

		-- filter out multicast and broadcast
		if ip > "E0" then return end
		
		-- country 
		local key,label = T.ldb_country:lookup_key(ip)
		if key then 
			TrisulPlugin.update_metrics(engine, flow, "{F962527D-985D-42FD-91D5-DA39F4D2A222}",  key, label) 
		end

		-- city 
		local key,label = T.ldb_city:lookup_key(ip)
		if key then 
			TrisulPlugin.update_metrics(engine, flow, "{E85FEB77-942C-411D-DF12-5DFCFCF2B932}",  key, label) 
			if not label:find("//",1,true) then 
				local flowpath=label:gsub("/","\\")
				TrisulPlugin.update_metrics(engine, flow, "{E44FC20C-2869-42E5-CCCC-074A962D832B}",  iphome_readable.."/"..key, iphome_readable.."\\"..flowpath) 
			end
		end

    end,

  },


	-- metrics updated
	update_metrics=function(engine, flow, guid, key, label) 

		local dir=0
		if T.host:is_homenet_key(flow:flow():ipz()) then 
			dir=1
		end 

		engine:update_counter ( guid ,  key, 3, 1)

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
