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
  	json_alerts_file = io.open("/tmp/suricata_alerts.json","r")
  end,

  inputfilter  = {


	-- 
	-- this function must either return nil or a table {..} with alert details
	-- Rule 1:  no blocking 
	-- Rule 2:  handle the JSON yourself here in LUA
	-- 
    step_alert  = function( )

		local n = json_alerts_file:read("*a");

		if not n then return nil; end

		local p = JSON:decode(n)


dbg()
		epoch_secs( p["timestamp"]);


		return {

			timestamp_secs = p["timestamp"],
			timestamp_usecs = p["timestamp"],

			source_ip = p["src_ip"],
			source_port = p["src_port"],
			destination_ip = p["dest_ip"],
			destination_port = p["dest_port"],
			protocol = p["proto"],

			sigid = p.alert["signature_id"],
			signame = p.alert["signature"],
			sigrev = p.alert["rev"],

			priority = p.alert["severity"],

			classification = p.alert["category"]
		};


	end


  }

}

epoch_secs = function( suri_rfc3339)
	local year , month , day , hour , min , sec , patt_end = 
				suri_rfc3339:match ( "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt](%d%d%.?%d*):(%d%d):(%d%d)()" )

end
