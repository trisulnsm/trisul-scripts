--
-- IPv6 to Trisul Key format 
-- 

local ffi=require'ffi'
local dbg=require'debugger'

ffi.cdef [[
	typedef uint32_t  socklen_t;
 	int inet_pton(int af, const char *src, void *dst);
  	const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);
    static const int AF_INET6=10;  
]]


IP6 = {}

function IP6.ip6_to_bin(ip6)
  local binip6 = ffi.new(' char  [16]') 
  ffi.C.inet_pton(ffi.C.AF_INET6, ip6, binip6);
  return  binip6
end

function IP6.bin2hex(binarr,len)
	  local h = {}
	  for i = 1 , len do 
	  	h[#h+1]=string.format("%02X",bit.band(binarr[i-1],0xff))
	  end
	  return table.concat(h) 
end 

function IP6.ip6_to_key(ip6)
	  return IP6.bin2hex(IP6.ip6_to_bin(ip6),16)

end

-- 2001:1900:5:2:2::2ae0/125
-- return start/end
function IP6.ip6_cidr(ip6, cidr)

	-- cidr masks
	local bitmask = ffi.new(' char  [16]') 
	local startoct = math.floor(cidr/8) 
	local maskbits=cidr-startoct*8
	local mask=math.pow(2,8-maskbits)-1
	for i = 1 , startoct  do 
		bitmask[i-1]=tonumber(0)
	end 
	for i = startoct+1, 16 do 
		bitmask[i-1]=tonumber(mask)
		mask=0xff
	end
	

	local ip6num = IP6.ip6_to_bin(ip6)

	for i=0, 15 do 
		ip6num[i]=bit.bor(bitmask[i],ip6num[i])
	end 

	return IP6.ip6_to_key(ip6,16), IP6.bin2hex(ip6num,16)
end

function IP6.tests()
	print( IP6.ip6_to_key("fe80::a60:6eff:fed9:b6bd"))
	local f,l = IP6.ip6_cidr("2001:1900:5:2:2::2ae0",125)
	print(f.." to "..l)
end 

return IP6


