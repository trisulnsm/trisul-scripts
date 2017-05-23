--
--  kiwisyslog.lua
--
--  Type : InputFilter
--
--  Consume Netflow information exported from ARCSIGHT via KIWISYSLOG 
--
-- the format looks like this 
-- 2017-03-21 11:07:13,Local7.Debug,172.24.21.58,"""srcaddr=7338388383,SysUptime=3693443660,dst_as=00,dstport=80,DevicePort=52435,dstaddr=7338388383,pad1=0,pad2=0,output=1,Last=7338388383,prot=6,DeviceAddress=7338388383tcp_flags=26,dPkts=463,tos=0,First=7338388383,src_as=61999,dst_mask=27,unix_nsecs=0,count=30,src_mask=0,version=05,nexthop=8888888888,dOctets=33355,input=3,engine_type=0,unix_secs=1490079998,engine_id=0,reserved=0,srcport=32173,flow_sequence=1044333853"""

-- local dbg = require("debugger")

-- in trisul: ipv4 keys look like XX.XX.XX.XX 
function  toip_format( dotted_ip )
  local b1, b2, b3, b4 =  dotted_ip:match("(%d+).(%d+).(%d+).(%d+)")
  return string.format("%02X.%02X.%02X.%02X",b1, b2, b3, b4 ) 
end

-- in trisul: port keys look like p-XXXX
function toport_format( strkey)
  if strkey == nil then 
    return "p-0000"
  else 
    return string.format("p-%04X", strkey)
  end
end

-- in trisul: proto keys look like XX - UDP = IP proto 17 = 11 
function toproto_format( strkey)
  if strkey == nil then 
    return "p-0000"
  else 
    return string.format("%02X", strkey)
  end 
end


-- in trisul: flow keys look like
function toflow_format( dir, kf) 
  if dir=='AZ' then 
      return string.format("%sC:%s:%s_%s:%s_%s_%04X_%04X", 
      kf.prot, kf.srcaddr, kf.srcport, kf.dstaddr, kf.dstport, kf.DeviceAddress, kf.input, kf.output )
  else
      return string.format("%sC:%s:%s_%s:%s_%s_%04X_%04X", 
      kf.prot, kf.dstaddr, kf.dstport, kf.srcaddr, kf.srcport, kf.DeviceAddress, kf.output, kf.input )
  end
end


TrisulPlugin = {

    id = {
      name = "Import NETFLOW from KIWI SYSLOG",
      description = "NFSYSLOG",
    },

    onload = function()
      T.log("Opening input file : "..T.args);
    T.datafilename = T.args

    print("opening ".. T.args)
      datfile = io.open(T.datafilename)
      T.count = 0 
    end,


    onunload = function ()
      T.log("Bye closing");
      datfile:close();
    end,


    inputfilter  = {

      -- nextmetrics
      -- read the next line and update flow metrics 
      step  = function(packet, engine)


        local nextline = datfile:read()

        -- check if end of file, 
        -- then pipeline must shutdown by returning false 
        if nextline == nil or #nextline == 0 then
          return false
        end

        if nextline:match("^%s+$") then return true; end 

        local rec = {}
        for a,b in nextline:gmatch("([%w_]+)=(%w+)") do
          rec[a]=b
        end

        if rec.srcaddr  ==nil   then  return true; end 

        local keyformats = {}
        keyformats['srcaddr']=toip_format( T.util.ntop(rec.srcaddr));
        keyformats['dstaddr']=toip_format( T.util.ntop(rec.dstaddr))
        keyformats['DeviceAddress']=toip_format( T.util.ntop(rec.DeviceAddress))
        keyformats['srcport']=toport_format( rec.srcport)
        keyformats['dstport']=toport_format( rec.dstport)
        keyformats['prot']=toproto_format(rec.prot)
        keyformats['input']=tonumber( rec.input) 
        keyformats['output']=tonumber( rec.output)
        keyformats['InterfaceIn']=keyformats['DeviceAddress']..'_'..string.format("%04X",tonumber(rec.input))
        keyformats['InterfaceOut']=keyformats['DeviceAddress']..'_'..string.format("%04X",tonumber(rec.output))

        local src_home = T.host:is_homenet( T.util.ntop(rec.srcaddr));
        local dst_home = T.host:is_homenet( T.util.ntop(rec.dstaddr));

        local dir='ZA';
        if keyformats.srcport > keyformats.dstport then dir = "AZ";  end 

        keyformats['flow']=toflow_format(dir, keyformats)

        if T.count % 10000==0 then 
          print(T.count .. " flowid = "..  keyformats.flow)
        end 
        --[[
        print(" packet = "..  rec.dPkts)
        print(" bytes  = "..  rec.dOctets)
        print(" in     = "..  rec.input)
        print(" out    = "..  rec.output)
        print(" time   = "..  rec.unix_secs)
        print(" durn   = "..  rec.Last - rec.First)
        print(" dir    = "..  dir);
        ]] 
        T.count = T.count + 1

        packet:set_timestamp(rec.unix_secs);

        -- update metrics
        engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "TOTALBW", 0, rec.dOctets)

        if src_home and not dst_home then 
          engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_OUTOFHOME", 0, rec.dOctets)
        elseif not src_home and dst_home then 
          engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_INTOHOME", 0, rec.dOctets)
        elseif not src_home and not dst_home then 
          engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_TRANSIT", 0, rec.dOctets)
        else 
          engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_INTERNAL", 0, rec.dOctets)
        end 

        -- hosts 
        engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.srcaddr, 0, rec.dOctets)


        -- home/ext for src addr 
        if src_home then  
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.srcaddr, 6, rec.dOctets);
        else
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.srcaddr, 7, rec.dOctets);
        end

        if dir == 'AZ' then 
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.srcaddr, 1, rec.dOctets);
        else
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.srcaddr, 2, rec.dOctets );
        end 

        -- dst addr 
        engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.dstaddr, 0, rec.dOctets)
        if dst_home then  
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.dstaddr, 6, rec.dOctets);
        else
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.dstaddr, 7, rec.dOctets);
        end

        if dir == 'AZ' then 
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.dstaddr, 1, rec.dOctets);
        else
          engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  keyformats.dstaddr, 2, rec.dOctets );
        end 


        -- network layer
        engine:update_counter( "{E89BCD56-30AD-40F5-B1C8-8B7683F440BD}",  keyformats.prot, 0, rec.dOctets);

        -- apps 
        local useport  = keyformats.dstport
        if dir == 'ZA' then 
          useport = keyformats.srcport 
        end 

        engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  useport, 0, rec.dOctets);
        if src_home  then 
          engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  useport, 3, rec.dOctets);
        else
          engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  useport, 2, rec.dOctets);
        end 

        -- flow 
        if dir=="AZ" then 
          engine:update_flow( keyformats.flow, 0,rec.dOctets);
          engine:update_flow( keyformats.flow, 2,rec.dPkts);
          engine:new_flow_record( keyformats.flow,  rec.dOctets,0,  rec.dPkts,0);
        else 
          engine:update_flow( keyformats.flow, 1,rec.dOctets);
          engine:update_flow( keyformats.flow, 3,rec.dPkts);
          engine:new_flow_record( keyformats.flow,  0, rec.dOctets, 0,rec.dPkts);
        end 


        engine:set_flow_duration( keyformats.flow, (rec.Last - rec.First)/100);

        local COUNTER_GUIDS = {
          flowgen  = '{2314BB8E-2BCC-4B86-8AA2-677E5554C0FE}',
          flowintf = '{C0B04CA7-95FA-44EF-8475-3835F3314761}'
        }

        engine:update_counter( COUNTER_GUIDS.flowgen,  keyformats.DeviceAddress, 0, rec.dOctets);
        engine:update_counter( COUNTER_GUIDS.flowgen,  keyformats.DeviceAddress, 1, rec.dOctets);
        engine:update_counter( COUNTER_GUIDS.flowgen,  keyformats.DeviceAddress, 1, 1);

        engine:update_counter( COUNTER_GUIDS.flowintf,  keyformats.InterfaceIn, 0, rec.dOctets);
        engine:update_counter( COUNTER_GUIDS.flowintf,  keyformats.InterfaceIn, 1, rec.dOctets);
        engine:update_counter( COUNTER_GUIDS.flowintf,  keyformats.InterfaceIn, 3, 1);

        engine:update_counter( COUNTER_GUIDS.flowintf,  keyformats.InterfaceOut, 0, rec.dOctets);
        engine:update_counter( COUNTER_GUIDS.flowintf,  keyformats.InterfaceOut, 2, rec.dOctets);
        engine:update_counter( COUNTER_GUIDS.flowintf,  keyformats.InterfaceOut, 3, 1);

        return true -- has more
            
    end,

  },

}


