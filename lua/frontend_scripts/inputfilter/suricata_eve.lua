-- suricata-eve.lua
--
-- Uses the input filter framework to accept EVE JSON events from Suricata IDS
-- and run them through the Trisul pipelines

local JSON = require'JSON';
local dbg = require'debugger';

TrisulPlugin = {

  id = {
    name = "EVE JSON Alerts ",
    description = "JSON Alerts fed into Trisul",
  },


  onload = function()
  	json_alerts_file = io.open("/tmp/eve.json","r")
  end,

  inputfilter  = {


	-- 
	-- this function must either return nil or a table {..} with alert details
	-- Rule 1:  no blocking 
	-- Rule 2:  handle the JSON yourself here in LUA
	-- 
    step_alert  = function( )

		local n = json_alerts_file:read("*l");
		print(n)


		local p = JSON:decode(n)

		

		-- we only deal with alerts 
	   if p["event_type"] ~=   "alert" then
	    print("ignoring event type ".. p["event_type"])
	   	return nil
	   end


		local tv_sec, tv_usec = epoch_secs( p["timestamp"]);

		local ret =  {

			timestamp_secs = tv_sec,
			timestamp_usecs = tv_usec,

			source_ip = p["src_ip"],
			source_port = p["src_port"],
			destination_ip = p["dest_ip"],
			destination_port = p["dest_port"],
			protocol = protocol_num(p["protocol"]),

			sigid = p.alert["signature_id"],
			signame = p.alert["signature"],
			sigrev = p.alert["rev"],

			priority = p.alert["severity"],

			classification = p.alert["category"]
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

