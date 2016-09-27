-- suricata-eve.lua
--
-- Uses the input filter framework to accept EVE JSON events from Suricata IDS
-- and run them through the Trisul pipelines

local JSON = require'JSON';
-- local dbg = require'debugger';

TrisulPlugin = {

  id = {
    name = "EVE JSON Alerts ",
    description = "JSON Alerts fed into Trisul",
  },


  onload = function()
  	json_alerts_file = io.open("/var/log/nsm/eve.json","r")
	local waldo_file = io.open("/nsm/trisul/lib/trisul-probe/domain0/probe0/context0/run/evejson.waldo","r")
	if waldo_file then
		json_alerts_file:seek("set", tonumber(waldo_file:read("*a")) )
		waldo_file:close() 
	end


  end,

  inputfilter  = {


	next_alert_line_json  = function()

		local n = json_alerts_file:read("*l");
		while n do 
		   local p = JSON:decode(n)
		   if p["event_type"] ==   "alert" then return p; end
		   n = json_alerts_file:read("*l");
		end
		return nil 
	end,

	-- 
	-- this function must either return nil or a table {..} with alert details
	-- Rule 1:  no blocking 
	-- Rule 2:  handle the JSON yourself here in LUA
	-- 
    step_alert  = function( )

		local p = TrisulPlugin.inputfilter.next_alert_line_json()
		if not p then return p; end

		local waldo_file = io.open("/nsm/trisul/lib/trisul-probe/domain0/probe0/context0/run/evejson.waldo","w")
		waldo_file:write( json_alerts_file:seek() )
		waldo_file:close()


		local tv_sec, tv_usec = epoch_secs( p["timestamp"]);

		local ret =  {

			AlertGroupGUID='{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}',     -- Trisul alert group = External IDS 
			TimestampSecs = tv_sec,										 -- Epoch based time stamps
			TimestampUsecs = tv_usec,
			SigIDKey = p.alert["signature_id"],                          -- SigIDKey is mandatory 
			SigIDLabel = p.alert["signature"],	                         -- User Label for the above SigIDKey 
			SourceIP = p["src_ip"],										 -- IP and Port pretty direct mappings
			SourcePort = p["src_port"],
			DestIP = p["dest_ip"],
			DestPort = p["dest_port"],
			Protocol = protocol_num(p["proto"]),						 -- convert TCP to 6 
			SigRev = p.alert["rev"],
			Priority = p.alert["severity"],
			ClassificationKey = p.alert["category"],
			AlertStatus=p.alert["action"],                                -- allowed/blocked like ALARM/CLEAR
			AlertDetails=p.alert["signature"]                             -- why waste a text field 'AlertDetails'?
		};


		return ret;


	end


  }

}

epoch_secs = function( suri_rfc3339)
	local year , month , day , hour , min , sec , tv_usec, patt_end = 
				suri_rfc3339:match ( "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt](%d%d%.?%d*):(%d%d):(%d%d).(%d+)+()" );

	local tv_sec  = os.time( { year = year, month = month, day = day, hour = hour, min = min, sec = sec});

	return tv_sec,tv_usec 

end

protocol_num = function(protoname)

	if protoname == "TCP" then return 6 
	elseif protoname == "UDP" then return 11
	elseif protoname == "ICMP" then return 1
	else return 0; end 

end

