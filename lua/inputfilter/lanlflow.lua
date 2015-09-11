--
-- lanlflow.lua
--
-- 	custom input filter for Trisul to process the sample flow DB
--  published by lanl at ... 
--
local dbg = require("debugger")

-- helpers

function  toip_format( strkey, T)
	local h = T.util.hash(strkey,32);
	local hs = string.format("%02X.%02X.%02X.%02X",
						 T.util.bitval32(h,31,8),
						 T.util.bitval32(h,22,8),
						 T.util.bitval32(h,15,8),
						 T.util.bitval32(h,7,8));

	return hs
end

function isport_number( strkey)
	local m = strkey:find("^[a-zA-Z]")
	if m  then
		return false
	else
		return true
	end

end


function toport_format( strkey, T)
	
	local portnum = 0
	if isport_number(strkey)   then
		portnum = tonumber(strkey)
	else
		portnum = T.util.hash(strkey,16);
	end
	
	local ps = string.format("p-%04X", portnum)
	return ps
end


function toflow_format( ipa, pra, ipz, prz, proto )

	if ipa < ipz then 
		return string.format("%02XA:%s:%s_%s:%s", proto, ipa, pra,ipz, prz ), 0
	else
		return string.format("%02XA:%s:%s_%s:%s", proto, ipz, prz,ipa, pra ), 1
	end

end


TrisulPlugin = {

	id = {
		name = "LANL format custom input filter ",
		description = "Custom Filter ",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	onload = function()
		T.host:log(T.K.loglevel.INFO, 
				"OnLoad Custom Input filter LUA plugin, Hi!  - ready ");

		datfile = io.open("flows.txt")

	end,


	onunload = function ()
		T.host:log(T.K.loglevel.INFO, 
				"OnUnload Custom Input filter LUA plugin, bye!");
	end,


	inputfilter  = {

		-- nextmetrics
		-- 	Called each packet 
		-- 	read the next line from the file and do engine:updateXXX(..) to add metrics 
		step  = function(packet, engine)


			local nextline = datfile:read()



			-- check if end of file, then pipeline must shutdown 
			if nextline == nil or #nextline == 0 then
				return false
			end

			local fields = T.util.split(nextline,",")

			packet:set_timestamp(tonumber(fields[1]),1)


			-- ip source 
			local ipa=toip_format(   fields[3], T)
			local pra=toport_format( fields[4], T)
			local ipz=toip_format(   fields[5], T)
			local prz=toport_format( fields[6], T)
			local proto=string.format("%02X", tonumber(fields[7]));
			local flw, flw_meter =toflow_format( ipa,pra,ipz,prz,proto)


			-- update metrics
			engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "TOTALBW", 0, tonumber(fields[9]))

			-- hosts 
			engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipa, 0, tonumber(fields[9]))
			engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipz, 0, tonumber(fields[9]))

			-- update host keys 
			engine:update_key_info( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipa, fields[3] )
			engine:update_key_info( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  ipz, fields[5] )

			if not isport_number(pra) then
				engine:update_key_info( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  pra, fields[4])
			end 

			if not isport_number(prz) then
				engine:update_key_info( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  prz, fields[6])
			end 

			-- network layer
			engine:update_counter( "{E89BCD56-30AD-40F5-B1C8-8B7683F440BD}",  proto, 0, tonumber(fields[9]))


			-- apps
			if isport_number(pra) then
				engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  pra, 0, tonumber(fields[9]))
			elseif isport_number(prz) then 
				engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  prz, 0, tonumber(fields[9]))
			elseif pra<prz then 
				engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  pra, 0, tonumber(fields[9]))
			else 
				engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  prz, 0, tonumber(fields[9]))
			end 
			
			-- flow 
			engine:update_flow( flw, flw_meter, tonumber(fields[9]))

			engine:set_flow_duration( flw, tonumber(fields[2]))

			

			return true -- has more
			
		end,


	 },

}

