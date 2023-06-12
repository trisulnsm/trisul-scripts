--
-- NAT syslog counter attached to SYSLOG protocol 
-- 
local Fk = require'flowkey' 
local SB=require'sweepbuf'


MONTHNAMES = {
  ['Jan'] = 1, ['Feb'] = 2, ['Mar'] = 3,
  ['Apr'] = 4, ['May'] = 5, ['Jun'] = 6,
  ['Jul'] = 7, ['Aug'] = 8, ['Sep'] = 9,
  ['Oct'] = 10, ['Nov'] = 11, ['Dec'] = 12,
}

PROTOCOl={
  ['ICMP'] = 1, ['IGMP'] = 2 , ['IPv4']=4,
  ['TCP'] = 6 , ['UDP'] = 17 , ['IPv6']=41
}

COUNTERID_FLOWGEN = "{2314BB8E-2BCC-4B86-8AA2-677E5554C0FE}" 

-- in trisul: ipv4 keys look like XX.XX.XX.XX 
function  toip_format( dotted_ip )
  local b1, b2, b3, b4 =  dotted_ip:match("(%d+).(%d+).(%d+).(%d+)")
  return string.format("%02X.%02X.%02X.%02X", b1, b2, b3, b4 )
end



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
    T.re2_NetElasticBNGNATSyslog=T.re2('19412\\s(SADD|SDEL)\\s\\[nsess\\sTRIG="(\\w+)"\\sPROTO="(\\d+)"\\sSSUBIX="(\\d)"\\sIATYP="(\\w+)"\\sUSERNAME="(\\w+)"\\sISADDR="(\\S+)"\\sIDADDR="(\\S+)"\\sISPORT="(\\d+)"\\sIDPORT="(\\d+)"\\sXATYP="(\\w+)"\\sXSADDR="(\\S+)"\\sXDADDR="(\\S+)"\\sXSPORT="(\\d+)"\\sXDPORT="(\\d+)"\\]\\stime=\'(\\d{4})-(\\d{2})-(\\d{2}) (\\d{2}):(\\d{2}):(\\d{2})\'')

    T.re2_HuaweiNATSyslog=T.re2(".*<NAT444>:<(\\w+)>\\s(\\d+)\\|(\\d+|-)\\|(\\S+)\\|(\\S+)\\|(\\d+)\\|(\\S+)\\|(\\d+)\\|(\\d+)")

    T.re2_JioDeviceNATSyslog=T.re2("<141>(\\w+)\\s+(\\d+)\\s+(\\d\\d):(\\d\\d):(\\d\\d)\\s+(\\S+)\\s+NAT_ACCT:(\\w+)\\s+(\\w+)\\s+SourceIp\\s+:(\\S+)\\s+Sourceport:(\\d+)\\s+TransIP\\s+:(\\S+)\\s+TransPort:(\\d+)\\s+DestIp\\s+:(\\S+)\\s+Destport:(\\d+)\\s*")

    T.re2_CiscoNATSyslog=T.re2("(\\w+)\\s+(\\d+)\\s+(\\d\\d):(\\d\\d):(\\d\\d).\\d\\d\\d.*(Created|Deleted)\\s+Translation\\s+(\\w+)\\s+(\\S+):(\\S+)\\s+(\\S+):(\\S+)\\s+(\\S+):(\\S+)\\s+(\\S+):(\\S+)\\s*\\d+")

    T.re2_CiscoNATSyslog2=T.re2("(\\w+)\\s+(\\d+)\\s+(\\d\\d):(\\d\\d):(\\d\\d).\\d\\d\\d.*(Created|Deleted)\\s+(\\w+)\\s+(\\S+):(\\d+)\\s+(\\S+):(\\d+)\\s+(\\S+):(\\d+)\\s+(\\S+):(\\d+)")

    --microkit has firwall in that syslog message
    T.re2_MikroTikNATSyslog=T.re2("firewall,info.*proto\\s(\\w+).*,\\s(\\S+):(\\d+)->(\\S+):(\\d+)")
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
      --ip_layer protocol
      local iplayer = layer:packet():find_layer("{0A2C724B-5B9F-4BA6-9C97-B05080558574}");
      local ip_sb = SB.new(iplayer:rawbytes():tostring())
      --skip to get ip
      ip_sb:skip(12)
      local iplayer_deviceip=ip_sb:next_ipv4()
      -- engine:add_resource( "{7B431613-9291-49BF-F8D3-73578A445310}", layer:packet():flowid():id(), "NAT SYSLOG", syslogstr) 


	  -- sources 
	  local ipkey = toip_format( iplayer_deviceip)
	  engine:update_counter( COUNTERID_FLOWGEN, ipkey, 0, #syslogstr)
	  engine:update_counter( COUNTERID_FLOWGEN, ipkey, 1, #syslogstr)
	  engine:update_counter( COUNTERID_FLOWGEN, ipkey, 2, 1)


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
        local fkey = Fk.toflow_format_v4( proto, tsip,tsport, dip, dport)
        if cmd == "Created" then
          engine:update_flow_raw( fkey, 0, 1)
          engine:tag_flow ( fkey, "[natip]"..sip)
          engine:tag_flow ( fkey, "[natport]"..sport)
          engine:tag_flow ( fkey, "[deviceip]"..iplayer_deviceip)


        elseif cmd == "Deleted" then 
          engine:update_flow_raw( fkey, 1, 1)
          engine:terminate_flow ( fkey)
        end 

      elseif syslogstr:find("%IPNAT-6-NAT",1,true) then 

        -- CISCO device 2 
        local bret, mon, day, h,m,s, cmd, proto, sip, sport, tsip, tsport, dip, dport = T.re2_CiscoNATSyslog2:partial_match_n(syslogstr)

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
          engine:tag_flow ( fkey, "[deviceip]"..sip)
        elseif cmd == "Deleted" then 
          engine:update_flow_raw( fkey, 1, 1)
          engine:terminate_flow ( fkey)
        end 

      elseif syslogstr:find("TRIG=",1,true) then 

        -- NetElastic BNG 
        local   bret,
            adddel,
            _,
            proto,
            _,
            ipversion,
            username,
            sip,
            dip,
            sport,
            dport,
            _,
            natip,
            _,
            natsport,
            _,
            year,
            mon,
            day,
            h,m,s= T.re2_NetElasticBNGNATSyslog:partial_match_n(syslogstr)


        if bret ==false then return; end

        local tvsec = os.time( {
          year =  tonumber(year),
          month = tonumber(mon),
          day   = tonumber(day),
          hour =h, min = m, sec = s
        })
        local fkey = Fk.toflow_format_v4( proto, natip,sport, dip, dport)

        if adddel == "SADD" then
          engine:update_flow_raw( fkey, 0, 1)
          engine:tag_flow ( fkey, "[natip]"..sip)
          engine:tag_flow ( fkey, "[natport]"..natsport)
          engine:tag_flow ( fkey, "[username]"..username)
          engine:tag_flow ( fkey, "[addts]"..tvsec)
          engine:tag_flow ( fkey, "[deviceip]"..iplayer_deviceip)
        elseif adddel == "SDEL" then 
          engine:update_flow_raw( fkey, 1, 1)
          engine:tag_flow ( fkey, "[delts]"..tvsec)
          engine:tag_flow ( fkey, "[deviceip]"..iplayer_deviceip)
          engine:terminate_flow ( fkey)
        end 

      elseif syslogstr:find(":<Session",1,true) then 
        -- Huawei device 
        local   bret,
            adddel,
            stvsec,
            etvsec,
            sip,
            natip,
            sport,
            dip,
            dport,
            proto= T.re2_HuaweiNATSyslog:partial_match_n(syslogstr)
        if bret ==false then return; end
        local fkey = Fk.toflow_format_v4( proto, natip,sport, dip, dport)
        if adddel == "SessionA" then
          engine:update_flow_raw( fkey, 0, 1)
          engine:tag_flow ( fkey, "[natip]"..sip)
          engine:tag_flow ( fkey, "[addts]"..stvsec)
          engine:tag_flow ( fkey, "[deviceip]"..iplayer_deviceip)

        elseif adddel == "SessionW" then 
          engine:update_flow_raw( fkey, 1, 1)
          engine:tag_flow ( fkey, "[delts]"..etvsec)
          engine:tag_flow ( fkey, "[deviceip]"..iplayer_deviceip)
          engine:terminate_flow ( fkey)
        end 
       elseif syslogstr:find("firewall,info",1,true) then

        -- MikroTik device 
        local   bret,
            proto,
            sip,
            sport,
            dip,
            dport= T.re2_MikroTikNATSyslog:partial_match_n(syslogstr)
        if bret ==false then return; end
        proto = PROTOCOl[proto]
        local fkey = Fk.toflow_format_v4( proto, sip,sport, dip, dport)
        engine:update_flow_raw( fkey, 0, 1)
        engine:tag_flow ( fkey, "[deviceip]"..iplayer_deviceip)
        engine:update_flow_raw( fkey, 1, 1)
        engine:terminate_flow ( fkey)

      end 
    end,
  },
}

