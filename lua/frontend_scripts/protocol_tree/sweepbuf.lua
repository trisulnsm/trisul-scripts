-- sweepbuf.lua
--  a one-pass scan buffer for packet dissection part of BITMAUL  
--
--  TODO: unoptimized  , see LuaJIT traces in prof directory
-- 

local SweepBuf  = {

  u8le = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)
  end,

  u8 = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)
  end,

  u16le = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos) +
           string.byte(tbl.buff,tbl.seekpos+1)*256;
  end,

  u24le = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos) +
           string.byte(tbl.buff,tbl.seekpos+1)*256 + 
           string.byte(tbl.buff,tbl.seekpos+2)*4096
  end,

  u32le = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos) +
           string.byte(tbl.buff,tbl.seekpos+1)*256 +
           string.byte(tbl.buff,tbl.seekpos+2)*4096 + 
           string.byte(tbl.buff,tbl.seekpos+3)*65536
  end,

  u16 = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)*256 +
           string.byte(tbl.buff,tbl.seekpos+1);
  end,

  u24 = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)*4096 +
           string.byte(tbl.buff,tbl.seekpos+1)*256 + 
           string.byte(tbl.buff,tbl.seekpos+2)
  end,

  u32 = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)*65536 +
           string.byte(tbl.buff,tbl.seekpos+1)*4096 +
           string.byte(tbl.buff,tbl.seekpos+2)*256 + 
           string.byte(tbl.buff,tbl.seekpos+3)
  end,

  peek_u8 = function(tbl, offset)
    tbl:inc(offset)
    local ret  = tbl:u8()
    tbl:inc(-offset)
    return ret
  end,
  peek_u16 = function(tbl, offset)
    tbl:inc(offset)
    local reclen  = tbl:u16()
    tbl:inc(-offset)
    return reclen
  end,
  peek_u24 = function(tbl, offset)
    tbl:inc(offset)
    local reclen  = tbl:u24()
    tbl:inc(-offset)
    return reclen
  end,
  peek_u32 = function(tbl, offset)
    tbl:inc(offset)
    local reclen  = tbl:u32()
    tbl:inc(-offset)
    return reclen
  end,

  next_u8_le = function(tbl)
    local r = tbl:u8()
    tbl:inc(1)
    return r
  end,

  next_u8 = function(tbl)
    local r = tbl:u8()
    tbl:inc(1)
    return r
  end,

  -- 
  next_uN = function(tbl, nbytes)
    local r 
	if nbytes==1 then 
		r=tbl:next_u8()
	elseif nbytes==2 then
		r=tbl:next_u16()
	elseif nbytes==3 then
		r=tbl:next_u24()
	elseif nbytes==4 then
		r=tbl:next_u32()
	elseif nbytes==0 then
		return nil
	else
		error("next_uN : only supports 1,2,3,4 byte numbers. Given="..nbytes)
	end
    return r
  end,

  next_uN_enum = function(tbl, nbytes, enumvals)
    local r = tbl:next_uN(nbytes)
	if enumvals[r] then 
		return {r,enumvals[r]}
	else 
		return {r,""} 
	end 
  end,
  
  -- ret[1]=value, ret[2]=enum 
  next_u8_enum = function(tbl, enumvals )
    local r = tbl:u8()
    tbl:inc(1)
	if enumvals[r] then 
		return {r,enumvals[r]}
	else 
		return {r,""} 
	end 
  end,


  next_u8_arr = function(tbl,nitems)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u8()
      nitems = nitems - 1
    end
    return ret;
  end,

  next_u8_enum_arr = function(tbl,nitems, enumvals)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u8_enum( enumvals)
      nitems = nitems - 1
    end
    return ret;
  end,

  next_u16 = function(tbl)
    return tbl:next_u8()*256 + tbl:next_u8()
  end,

  next_u16_le = function(tbl)
    return tbl:next_u8() + tbl:next_u8()*256
  end,


  next_str_to_pattern = function(tbl, patt, is_plain)
  	is_plain=is_plain or true 
    local f,l =string.find(tbl.buff,patt,tbl.seekpos,is_plain)  -- last param = false=regex, true=not-regex 
    if f then
        local r = string.sub(tbl.buff,tbl.seekpos,l)
        tbl.seekpos = l+1
        return r
    else
        return nil 
    end
  end,

  -- exclude the pattern matched 
  next_str_to_pattern_exclude = function(tbl, patt, is_plain)
  	is_plain=is_plain or true 
    local f,l =string.find(tbl.buff,patt,tbl.seekpos+1,is_plain)  -- last param = false=regex, true=not-regex 
    if f then
        local r = string.sub(tbl.buff,tbl.seekpos,f-1)
        tbl.seekpos = f
        return r
    else
        return nil 
    end
  end,

  next_str_to_len = function(tbl, slen)
    if tbl:bytes_left() >= slen then 
      local r = string.sub(tbl.buff,tbl.seekpos,tbl.seekpos+slen-1)
      tbl:inc(slen)
      return r
    else
      return nil
    end 
  end,

  next_hex_str_to_len = function(tbl, slen)
  	local ret = tbl:next_str_to_len(slen)
	if ret then
	    return (ret:gsub('.', function (c)
		        return string.format('%02X', string.byte(c))
		end))
	else
		return nil
	end
  end,

  next_u16_arr = function(tbl,nitems)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u16()
      nitems = nitems - 1
    end
    return ret;
  end,

  next_u24 = function(tbl)
    return tbl:next_u8()*4096 + tbl:next_u8()*256 + tbl:next_u8()
  end,

  next_u24_le = function(tbl)
    return tbl:next_u8()+ tbl:next_u8()*256 + tbl:next_u8()*4096
  end,

  next_u32 = function(tbl)
    return tbl:next_u16()*65536 + tbl:next_u16() 
  end,

  next_u32_le = function(tbl)
    return tbl:next_u8()+ tbl:next_u8()*256 + tbl:next_u8()*4096 + tbl:next_u8()*65536
  end,

  next_u32_arr = function(tbl,nitems)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u32()
      nitems = nitems - 1
    end
    return ret;
  end,

  inc = function(tbl, n)
    tbl.seekpos = tbl.seekpos + n 
  end,

  skip = function(tbl, n)
    tbl.seekpos = tbl.seekpos + n 
    return true
  end,

  reset = function(tbl)
    tbl.seekpos=1
    tbl.fence={#tbl.buff}
  end,

  top_fence = function(tbl)
    return tbl.fence[#tbl.fence]
  end,

  has_more = function(tbl)
    return tbl.seekpos < tbl:top_fence() 
  end,

  buffer_left = function(tbl)
    return string.sub(tbl.buff ,tbl.seekpos+1, #tbl.buff)
  end, 

  bytes_left = function(tbl)
    return #tbl.buff - tbl.seekpos + 1
  end,

  abs_seek  = function(tbl) 
    return tbl.left + tbl.seekpos
  end,

  push_fence = function(tbl,delta_ahead)
    tbl.fence[#tbl.fence+1] = tbl.seekpos + delta_ahead
  end ,

  pop_fence = function(tbl)
    tbl.fence[#tbl.fence]=nil 
  end,

  bytes_left_to_fence=function(tbl)
    return tbl.top_fence(tbl)-tbl.seekpos
  end,

  split = function(tbl, str, delim)
    local ret = {}
    for word in str:gmatch("([^,]+)") do
      ret[#ret+1]=word
    end
    return ret
  end,

  next_bitfield_u8 = function(tbl, bitmap)
	local v=tbl.next_u8(tbl)
  	local nleft=8
	local i=1
	local ret={}
	while nleft > 0 and i <= #bitmap do
		local w=bitmap[i]
		local m=math.pow(2,w)-1
		local mask=bit.lshift(m,nleft-w)
		local val1=bit.band(mask,v)
		local val2=bit.rshift(val1,nleft-w)
		ret[#ret+1]=val2 
		nleft=nleft-w
		i=i+1
	end
	return ret
  end, 

  next_bitfield_u16 = function(tbl, bitmap)
	local v=tbl.next_u16(tbl)
  	local nleft=16
	local i=1
	local ret={}
	while nleft > 0 and i <= #bitmap do
		local w=bitmap[i]
		local m=math.pow(2,w)-1
		local mask=bit.lshift(m,nleft-w)
		local val1=bit.band(mask,v)
		local val2=bit.rshift(val1,nleft-w)
		ret[#ret+1]=val2 
		nleft=nleft-w
		i=i+1
	end
	return ret
  end,


  -- 8-bit fields with fieldnames
  next_bitfield_u8_named  = function(tbl, bitmap, fieldnames )
  	local values=tbl:next_bitfield_u8(bitmap)
	local ret={}

	for i = 1 , #values do 
		ret[fieldnames[i]]=values[i]
	end 

	return ret
  end, 


  -- 16-bits with fieldnames 
  next_bitfield_u16_named  = function(tbl, bitmap, fieldnames )
  	local values=tbl:next_bitfield_u16(bitmap)
	local ret={}
	for i = 1 , #values do 
		ret[fieldnames[i]]=values[i]
	end 
	return ret
  end, 


  next_ipv4 = function(tbl)
  	return string.format("%d.%d.%d.%d", tbl:next_u8(), tbl:next_u8(), tbl:next_u8(), tbl:next_u8())
  end,

  next_ipv4_arr = function(tbl, nitems )
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_ipv4()
      nitems = nitems - 1
    end
    return ret;
  end,

  next_mac = function(tbl)
  	return string.format("%02X:%02X:%02X:%02X:%02X:%02X", tbl:next_u8(), tbl:next_u8(), tbl:next_u8(), tbl:next_u8(), tbl:next_u8(), tbl:next_u8() )
  end,
  
  -- attr_value_regex = 2 captures 
  split_fields=function(tbl, attr_value_regex)

	local fields = {}
  	for k,v in tbl.buff:gmatch(attr_value_regex) do 
		fields[k]=v
	end
	return fields

  end,

  -- split_fields_fast : No regex in delim 
  split_fields_fast=function(tbl, delim_name, delim_record)

  	local len=#tbl.buff
	local pos=tbl.seekpos

	local ret={}

	while pos<len-#delim_record do
		local f1,l1 = string.find(tbl.buff, delim_name, pos, true)
		local f2,l2 = string.find(tbl.buff, delim_record, l1+1, true)

		local f=string.sub(tbl.buff,pos,f1-1)
		local v=string.sub(tbl.buff,l1+1,f2-1)
		pos=l2+1

		ret[f]=v
	end 

	return ret
  end,


  hexdump = function(tbl )
    local offset=1
    local bytes_per_line=16
    while offset < #tbl.buff  do
      io.write(string.format("%08X ", offset-1))
      local bytes = string.sub(tbl.buff,offset,offset+bytes_per_line-1)
      for b in bytes:gmatch('.') do
        io.write(('%02X '):format(b:byte()))
      end
      io.write(('   '):rep(bytes_per_line - bytes:len() + 1))
      io.write(bytes:gsub('[^%g]', '.'), '\n')
      offset = offset + bytes_per_line
    end
  end,


}


-- metatbl - use a common mt (LuaJIT opt)
local smt = {
    __index = SweepBuf,

    __le    = function(s1, s2) 
                return s1.left >= s2.left and s1.right <= s2.right
              end,

    __add   = function(s1, s2) 
                local ol = s1.right-s2.left
                local newbuff = string.sub(s1.buff,s1.seekpos).. string.sub(s2.buff,ol+1)
                return setmetatable({
                  left=s1.left,
                  right=s2.right,
                  seekpos=1,
                  buff = newbuff,
                  fence={#newbuff}
                },getmetatable(s1));
              end,

    __tostring = function(s)
                   return string.format( "SB: Len=%d Seek=%d Avail=%d L=%d R=%d F=%d", #s.buff, s.seekpos, s:bytes_left(), s.left, s.right, s:top_fence() )
                 end
}

local sweepbuf = { 

   new = function( rawbuffer , pos) 
       pos = pos or 1 
       return setmetatable(  {
          buff=rawbuffer,
          left=pos,
          right=pos+#rawbuffer,
          seekpos=1,
          fence={#rawbuffer} 
        },smt)

    end
} 

return sweepbuf 

