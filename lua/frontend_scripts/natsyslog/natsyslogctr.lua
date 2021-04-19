--
-- NAT syslog counter attached to SYSLOG protocol 
-- 
local Fk = require'flowkey' 

MONTHNAMES = {
	['Jan'] = 1, ['Feb'] = 2, ['Mar'] = 3,
	['Apr'] = 4, ['May'] = 5, ['Jun'] = 6,
	['Jul'] = 7, ['Aug'] = 8, ['Sep'] = 9,
	['Oct'] = 10, ['Nov'] = 11, ['Dec'] = 12,
}

TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "SYGLOG  packet monitor",
    description = "Listen to SYSLOG packets", 
  },

  -- COMMON FUNCTIONS:  onload, onunload, onmessage 
  -- 
  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()

	T.re2_JioDeviceNATSyslog=T.re2("<141>(\\w+)\\s+(\\d+)\\s+(\\d\\d):(\\d\\d):(\\d\\d)\\s+(\\S+)\\s+NAT_ACCT:(\\w+)\\s+(\\w+)\\s+SourceIp\\s+:(\\S+)\\s+Sourceport:(\\d+)\\s+TransIP\\s+:(\\S+)\\s+TransPort:(\\d+)\\s+DestIp\\s+:(\\S+)\\s+Destport:(\\d+)\\s*")

	T.re2_CiscoNATSyslog=T.re2("(\\w+)\\s+(\\d+)\\s+(\\d\\d):(\\d\\d):(\\d\\d).\\d\\d\\d.*(Created|Deleted)\\s+Translation\\s+(\\w+)\\s+(\\S+):(\\S+)\\s+(\\S+):(\\S+)\\s+(\\S+):(\\S+)\\s+(\\S+):(\\S+)\\d+")

  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    -- your code 
  end,

  simplecounter = {

	-- to UDP>SYSLOG protocol 
    protocol_guid = "{4323003E-D060-440B-CA26-E146C0C7DB4E}", 

    onpacket = function(engine,layer)
		local syslogstr = layer:rawbytes():tostring()

		if syslogstr:find("NAT_ACCT",1,true) then 
			-- JIO device 

			local bret, mon, day, h,m,s, deviceip, cmd, proto, sip, sport, tsip, tsport, dip, dport = T.re2_JioDeviceNATSyslog:partial_match_n(syslogstr)

			if bret ==false then return;  end

			local tvsec = os.time( {
				year = tonumber(os.date('%Y')),
				month = MONTHNAMES[mon],
				day = tonumber(day),
				hour =h, min = m, sec = s
			})
			local fkey = Fk.toflow_format_v4( proto, sip,sport, dip, dport)

			if cmd == "START" then
				engine:update_flow_raw( fkey, 0, 1)
				engine:tag_flow ( fkey, "[natip]"..tsip)
				engine:tag_flow ( fkey, "[natport]"..tsport)
				engine:tag_flow ( fkey, "[deviceip]"..deviceip)
			elseif cmd == "STOP" then 
				engine:terminate_flow ( fkey)
			end 

		elseif syslogstr:find("LOG_TRANSLATION",1,true) then 

			-- CISCO device 
			local bret, mon, day, h,m,s, cmd, proto, sip, sport, tsip, tsport, dip, dport = T.re2_CiscoNATSyslog:partial_match_n(syslogstr)

			if bret ==false then return; end

			local tvsec = os.time( {
				year = tonumber(os.date('%Y')),
				month = MONTHNAMES[mon],
				day = tonumber(day),
				hour =h, min = m, sec = s
			})
			local fkey = Fk.toflow_format_v4( proto, sip,sport, dip, dport)

			if cmd == "Created" then
				engine:update_flow_raw( fkey, 0, 1)
				engine:tag_flow ( fkey, "[natip]"..tsip)
				engine:tag_flow ( fkey, "[natport]"..tsport)
			elseif cmd == "Deleted" then 
				engine:terminate_flow ( fkey)
			end 

		end 
    end,
  },
}

