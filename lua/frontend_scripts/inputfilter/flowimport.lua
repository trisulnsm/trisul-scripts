--
-- flowimport.lua 
--
-- Library to import arbitrary flow like information into Trisul using inputfilter framework 
--
--
-- Usage : you fill out the following table and call process_flow_flowtbl.rd(..) 
-- 
-- local FI = require'FlowImporter'
--
-- FI.process_flow( engine,  {
--      first_timestamp:        <number>,   -- unix epoch secs when flow first seen
--      last_timestamp:         <number>,   -- unix epoch secs  when last seen 
--      router_ip:              <ipaddr>,   -- router (exporter ip) dotted ip format
--      protocol:               <number>,   -- ip protocol number 0-255
--      source_ip:              <ipaddr>,   -- dotted ip format
--      source_port:            <number>,   -- source port number 0-65535
--      destination_ip:         <ipaddr>,   -- dotted ip 
--      destination_port:       <number>,   -- source port number 0-65535
--      input_interface:        <number>,   -- ifIndex IN of flow 0-65535
--      output_interface:       <number>,   -- ifIndex OUT of flow 0-65535
--      bytes:                  <number>,   -- octets, 
--      packets:                <number>,   -- packets 
--      -- optional --                      
--      bytes_out:              <number>,   -- octets in Src->Dest diflowtbl.ion
--      packets_out:            <number>,   -- packets in Src->Dest diflowtbl.ion
--      bytes_in:               <number>,   -- octets in Dest->Src diflowtbl.ion
--      packets_in:             <number>,   -- packets in Dest->Src diflowtbl.ion
--      as:                     <number>,   -- ASN (0-65535)
--      tos:                    <number>,   -- IP TOS 
-- })
--
-- For a working example see kiwisyslog.lua on trisul-script@github 
-- 
-- local dbg=require'debugger'

local FlowImporter = {}



FlowImporter.toip_format = function( dotted_ip )
  local b1, b2, b3, b4 =  dotted_ip:match("(%d+).(%d+).(%d+).(%d+)")
  return string.format("%02X.%02X.%02X.%02X",b1, b2, b3, b4 ) 
end

-- in trisul: port keys look like p-XXXX
FlowImporter.toport_format=function( strkey)
  if strkey == nil then 
    return "p-0000"
  else 
    return string.format("p-%04X", strkey)
  end
end

-- in trisul: proto keys look like XX - UDP = IP proto 17 = 11 
FlowImporter.toproto_format=function( strkey)
  if strkey == nil then 
    return "p-0000"
  else 
    return string.format("%02X", strkey)
  end 
end

FlowImporter.toflow_format=function( dir, tkey)
  if dir=='AZ' then 
      return string.format("%sC:%s:%s_%s:%s_%s_%04X_%04X", 
              tkey.protocol,   tkey.source_ip,   tkey.source_port,   
              tkey.destination_ip,   tkey.destination_port, 
              tkey.router_ip,   tkey.input_interface_number,   tkey.output_interface_number ) 
  else
      return string.format("%sC:%s:%s_%s:%s_%s_%04X_%04X", 
              tkey.protocol,   tkey.destination_ip,   tkey.destination_port, 
              tkey.source_ip,   tkey.source_port,   
              tkey.router_ip,   tkey.output_interface_number,   tkey.input_interface_number ) 
  end
end

FlowImporter.process_flow=function(engine, flowtbl)

    -- convert the incoming raw entities into Trisul Key Formats
    --
    local tkey = {
         router_ip = FlowImporter.toip_format(  flowtbl.router_ip),
         protocol = FlowImporter.toproto_format(  flowtbl.protocol),
         source_ip = FlowImporter.toip_format(  flowtbl.source_ip),
         source_port = FlowImporter.toport_format(  flowtbl.source_port),
         destination_ip = FlowImporter.toip_format(  flowtbl.destination_ip),
         destination_port = FlowImporter.toport_format(  flowtbl.destination_port),
         input_interface_number = flowtbl.input_interface,
         output_interface_number = flowtbl.output_interface
    }
    tkey.input_interface = tkey.router_ip..'_'..string.format("%04X",tonumber(flowtbl.input_interface))
    tkey.output_interface = tkey.router_ip..'_'..string.format("%04X",tonumber(flowtbl.output_interface))


    -- home network perspective 
    local src_home = T.host:is_homenet( flowtbl.source_ip)
    local dst_home = T.host:is_homenet( flowtbl.destination_ip)

    -- flow ke
    local dir='ZA';
    if tkey.source_port > tkey.destination_port then dir = "AZ";  end 

    tkey.flow=FlowImporter.toflow_format(dir, tkey)

    -- update metrics
    engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "TOTALBW", 0, flowtbl.bytes)

    if src_home and not dst_home then 
      engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_OUTOFHOME", 0, flowtbl.bytes)
    elseif not src_home and dst_home then 
      engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_INTOHOME", 0, flowtbl.bytes)
    elseif not src_home and not dst_home then 
      engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_TRANSIT", 0, flowtbl.bytes)
    else 
      engine:update_counter( "{393B5EBC-AB41-4387-8F31-8077DB917336}", "DIR_INTERNAL", 0, flowtbl.bytes)
    end 

    -- hosts 
    engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.source_ip, 0, flowtbl.bytes)


    -- home/ext for src addr 
    if src_home then  
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.source_ip, 6, flowtbl.bytes);
    else
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.source_ip, 7, flowtbl.bytes);
    end

    if dir == 'AZ' then 
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.source_ip, 1, flowtbl.bytes);
    else
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.source_ip, 2, flowtbl.bytes );
    end 

    -- dst addr 
    engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.destination_ip, 0, flowtbl.bytes)
    if dst_home then  
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.destination_ip, 6, flowtbl.bytes);
    else
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.destination_ip, 7, flowtbl.bytes);
    end

    if dir == 'AZ' then 
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.destination_ip, 1, flowtbl.bytes);
    else
      engine:update_counter( "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  tkey.destination_ip, 2, flowtbl.bytes );
    end 


    -- network layer
    engine:update_counter( "{E89BCD56-30AD-40F5-B1C8-8B7683F440BD}",  tkey.protocol, 0, flowtbl.bytes);

    -- apps 
    local useport  = tkey.destination_port
    if dir == 'ZA' then 
      useport = tkey.source_port 
    end 

    engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  useport, 0, flowtbl.bytes);
    if src_home  then 
      engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  useport, 3, flowtbl.bytes);
    else
      engine:update_counter( "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",  useport, 2, flowtbl.bytes);
    end 

    -- flow 
    if dir=="AZ" then 
      engine:update_flow( tkey.flow, 0,flowtbl.bytes);
      engine:update_flow( tkey.flow, 2,flowtbl.packets);
      engine:new_flow_record( tkey.flow,  flowtbl.bytes,0,  flowtbl.packets,0);
    else 
      engine:update_flow( tkey.flow, 1,flowtbl.bytes);
      engine:update_flow( tkey.flow, 3,flowtbl.packets);
      engine:new_flow_record( tkey.flow,  0, flowtbl.bytes, 0,flowtbl.packets);
    end 

    engine:set_flow_duration( tkey.flow, (flowtbl.last_timestamp - flowtbl.first_timestamp)/100);

    local COUNTER_GUIDS = {
      flowgen  = '{2314BB8E-2BCC-4B86-8AA2-677E5554C0FE}',
      flowintf = '{C0B04CA7-95FA-44EF-8475-3835F3314761}',
      apps     =  "{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}",
      hosts    = "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}",  
      protocols= "{E89BCD56-30AD-40F5-B1C8-8B7683F440BD}",
      aggregates= "{393B5EBC-AB41-4387-8F31-8077DB917336}"
    }

    engine:update_counter( COUNTER_GUIDS.flowgen,  tkey.router_ip, 0, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowgen,  tkey.router_ip, 1, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowgen,  tkey.router_ip, 1, 1);

    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.input_interface, 0, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.input_interface, 1, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.input_interface, 3, 1);

    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.output_interface, 0, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.output_interface, 2, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.output_interface, 3, 1);

    return true -- has more
        
end


return FlowImporter;


