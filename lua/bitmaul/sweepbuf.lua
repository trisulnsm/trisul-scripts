-- sweepbuf.lua
-- 	a one-pass scan buffer 
-- 	for packet dissection 
--
-- 	TODO: unoptimized 
-- local dbg=require'debugger'
local SweepBuf  = {

  u8 = function(tbl)
    return string.byte(tbl.buff,tbl.seekpos)
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

  peek_u16 = function(tbl, offset)
	tbl:inc(offset)
	local reclen  = tbl:u16()
	tbl:inc(-offset)
	return reclen
  end,

  next_u8 = function(tbl)
    local r = tbl:u8()
    tbl:inc(1)
    return r
  end,

  next_u8_arr = function(tbl,nitems)
    local ret = {}
    while nitems > 0 do
      ret[#ret+1] = tbl:next_u8()
      nitems = nitems - 1
    end
    return ret;
  end,

  next_u16 = function(tbl)
    return tbl:next_u8()*256 + tbl:next_u8()
  end,

  next_str_to_pattern = function(tbl, patt)
  	local f =string.find(tbl.buff,patt,tbl.seekpos,true) 
  	if f then
  		local r = string.sub(tbl.buff,tbl.seekpos,f+#patt)
  		tbl.seekpos = f+#patt
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

  next_u32 = function(tbl)
    return tbl:next_u16()*65536 + tbl:next_u16() 
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

  split = function(tbl, str, delim)
      local ret = {}
	  for word in str:gmatch("([^,]+)") do
	      ret[#ret+1]=word
	  end
	  return ret
  end

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
	    }, smt)

	end
} 

return sweepbuf 
