-- flowimport_v6.lua 
--
-- Same as flowimport_v6.lua but for IPv6 addresses 
--
-- local dbg=require'debugger'

local FlowImporter = {}

local ffi=require'ffi'

ffi.cdef [[
 	int inet_pton(int af, const char *src, void *dst);
  static const int AF_INET6=10;  
]]

local COUNTER_GUIDS = {
  flowgen   = '{2314BB8E-2BCC-4B86-8AA2-677E5554C0FE}',
  flowintf  = '{C0B04CA7-95FA-44EF-8475-3835F3314761}',
  apps      = '{C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}',
  protocols = '{E89BCD56-30AD-40F5-B1C8-8B7683F440BD}',
  aggregates= '{393B5EBC-AB41-4387-8F31-8077DB917336}',
  hostsipv6 = '{9807E97A-6CD2-442F-BB18-8C104C8EB204}'
}

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
    return string.format("%sD:%s:%s_%s:%s_%s_%08X_%08X", 
            tkey.protocol,   tkey.source_ip,   tkey.source_port,   
            tkey.destination_ip,   tkey.destination_port, 
            tkey.router_ip,   tkey.input_interface_number,   tkey.output_interface_number ) 
  else
    return string.format("%sD:%s:%s_%s:%s_%s_%08X_%08X", 
            tkey.protocol,   tkey.destination_ip,   tkey.destination_port, 
            tkey.source_ip,   tkey.source_port,   
            tkey.router_ip,   tkey.output_interface_number,   tkey.input_interface_number ) 
  end

end

FlowImporter.process_flow=function(engine, flowtbl)

    -- defaults if there are no netflow
    if flowtbl.router_ip==nil then
      flowtbl.router_ip="0.0.0.0"
      flowtbl.input_interface=0
      flowtbl.output_interface=0
    end 

    -- convert the incoming raw entities into Trisul Key Formats
    --
    local tkey = {
      router_ip = FlowImporter.toip_v4_format(  flowtbl.router_ip),
      protocol = FlowImporter.toproto_format(  flowtbl.protocol),
      source_ip = FlowImporter.toip_v6_format(  flowtbl.source_ip),
      source_port = FlowImporter.toport_format(  flowtbl.source_port),
      destination_ip = FlowImporter.toip_v6_format(  flowtbl.destination_ip),
      destination_port = FlowImporter.toport_format(  flowtbl.destination_port),
      input_interface_number = tonumber(flowtbl.input_interface),
      output_interface_number = tonumber(flowtbl.output_interface)
    }
    tkey.input_interface = tkey.router_ip..'_'..string.format("%08X",tonumber(flowtbl.input_interface))
    tkey.output_interface = tkey.router_ip..'_'..string.format("%08X",tonumber(flowtbl.output_interface))

    -- home network perspective  (todo - right now assume source is home ) 
    local src_home = true
    local dst_home = false

    -- flow ke
    local dir='ZA';
    if tkey.source_port > tkey.destination_port then dir = "AZ";  end 

    tkey.flow=FlowImporter.toflow_format(dir, tkey)

	for k,v in pairs(tkey) do
		print( k .. ' = ' .. v)
	end
	print("\n")

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
    engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.source_ip, 0, flowtbl.bytes)


    -- home/ext for src addr 
    if src_home then  
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.source_ip, 6, flowtbl.bytes);
    else
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.source_ip, 7, flowtbl.bytes);
    end

    if dir == 'AZ' then 
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.source_ip, 1, flowtbl.bytes);
    else
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.source_ip, 2, flowtbl.bytes );
    end 

    -- dst addr 
    engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.destination_ip, 0, flowtbl.bytes)
    if dst_home then  
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.destination_ip, 6, flowtbl.bytes);
    else
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.destination_ip, 7, flowtbl.bytes);
    end

    if dir == 'AZ' then 
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.destination_ip, 1, flowtbl.bytes);
    else
      engine:update_counter( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.destination_ip, 2, flowtbl.bytes );
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

    engine:set_flow_duration( tkey.flow, flowtbl.last_timestamp - flowtbl.first_timestamp);

    engine:update_counter( COUNTER_GUIDS.flowgen,  tkey.router_ip, 0, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowgen,  tkey.router_ip, 1, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowgen,  tkey.router_ip, 1, 1);

    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.input_interface, 0, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.input_interface, 1, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.input_interface, 3, 1);

    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.output_interface, 0, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.output_interface, 2, flowtbl.bytes);
    engine:update_counter( COUNTER_GUIDS.flowintf,  tkey.output_interface, 3, 1);

    if flowtbl.source_label then
      engine:update_key_info( '{9807E97A-6CD2-442F-BB18-8C104C8EB204}',  tkey.source_ip, flowtbl.source_label)
    end 

    if flowtbl.input_interface_label then
      engine:update_key_info( COUNTER_GUIDS.flowintf,  tkey.input_interface, flowtbl.input_interface_label)
    end 

    if flowtbl.output_interface_label then
      engine:update_key_info( COUNTER_GUIDS.flowintf,  tkey.output_interface, flowtbl.output_interface_label)
    end 

    if flowtbl.router_label then
      engine:update_key_info( COUNTER_GUIDS.flowgen,  tkey.router_ip, flowtbl.router_label)
    end 

	if flowtbl.flowtags then
		for _,s in ipairs( flowtbl.flowtags) do
			if s then 
			  engine:tag_flow( tkey.flow, s) 
			end
		end
	end

    return true -- has more
        
end

FlowImporter.ip6_to_bin=function(ip6)
  local binip6 = ffi.new(' char  [16]') 
  ffi.C.inet_pton(ffi.C.AF_INET6, ip6, binip6);
  return  binip6
end

FlowImporter.bin2hex=function(binarr,len)
  local h = {}
  for i = 1 , len do 
  	h[#h+1]=string.format("%02X",bit.band(binarr[i-1],0xff))
  end
  return table.concat(h) 
end 

FlowImporter.toip_v6_format=function(ip6)
  return FlowImporter.bin2hex(FlowImporter.ip6_to_bin(ip6),16)
end

FlowImporter.toip_v4_format = function( dotted_ip )
  local b1, b2, b3, b4 =  dotted_ip:match("(%d+).(%d+).(%d+).(%d+)")
  return string.format("%02X.%02X.%02X.%02X",b1, b2, b3, b4 ) 
end

return FlowImporter;
