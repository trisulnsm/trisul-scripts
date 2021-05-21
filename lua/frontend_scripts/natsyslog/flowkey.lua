--
-- flowkey.lua 
--

local ffi=require'ffi'

ffi.cdef [[
 	int inet_pton(int af, const char *src, void *dst);
  static const int AF_INET6=10;  
]]

local FlowKey = {}

FlowKey.toip_format = function( dotted_ip )
  local b1, b2, b3, b4 =  dotted_ip:match("(%d+).(%d+).(%d+).(%d+)")
  return string.format("%02X.%02X.%02X.%02X",b1, b2, b3, b4 ) 
end

-- in trisul: port keys look like p-XXXX
FlowKey.toport_format=function( strkey)
  if strkey == nil then 
    return "p-0000"
  else 
    return string.format("p-%04X", strkey)
  end
end

-- in trisul: proto keys look like XX - UDP = IP proto 17 = 11 
FlowKey.toproto_format=function( strkey)
  if strkey == "tcp" or strkey == "TCP" then 
  	return "06"
  elseif strkey == "udp" or strkey == "UDP" then 
  	return "11"
  elseif strkey == "icmp" or strkey == "ICMP" then 
    return "01"
  else 
    return string.format("%02X", tonumber(strkey))
  end 
end

FlowKey.toflow_format_v4=function( proto, sip, sp, dip, dp)
  return string.format("%sA:%s:%s_%s:%s", 
		  FlowKey.toproto_format(proto),   FlowKey.toip_format(sip),   FlowKey.toport_format(sp),   
		  FlowKey.toip_format(dip),   FlowKey.toport_format(dp) )
end

FlowKey.toflow_format_v6=function( proto, sip, sp, dip, dp)
  return string.format("%sB:%s:%s_%s:%s", 
		  FlowKey.toproto_format(proto),   FlowKey.toip_v6_format(sip),   FlowKey.toport_format(sp),   
		  FlowKey.toip_v6_format(dip),   FlowKey.toport_format(dp) )
end 

FlowKey.ip6_to_bin=function(ip6)
  local binip6 = ffi.new(' char  [16]') 
  ffi.C.inet_pton(ffi.C.AF_INET6, ip6, binip6);
  return  binip6
end

FlowKey.bin2hex=function(binarr,len)
  local h = {}
  for i = 1 , len do 
  	h[#h+1]=string.format("%02X",bit.band(binarr[i-1],0xff))
  end
  return table.concat(h) 
end 

FlowKey.toip_v6_format=function(ip6)
  return FlowKey.bin2hex(FlowKey.ip6_to_bin(ip6),16)
end

return FlowKey

