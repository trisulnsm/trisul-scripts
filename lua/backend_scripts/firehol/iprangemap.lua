--  Range map, used to search through ip ranges or any other kind of range 
--  local dbg=require'debugger'

local srange = {
  __index = {} ,

  __eq = function( r1, r2 ) 
    return r1._from <= r2._to and r1._to >= r2._from
  end,  

  __lt = function( r1, r2 ) 
    return r1._from < r2._from and r1._to < r2._to
  end,  

  __tostring = function(r)
    local ff= string.format("%d.%d.%d.%d", bit.band(0xff,bit.rshift(r._from,24)),
          bit.band(0xff,bit.rshift(r._from,16)), bit.band(0xff,bit.rshift(r._from,8)), bit.band(0xff,bit.rshift(r._from,0)))

    local ft= string.format("%d.%d.%d.%d", bit.band(0xff,bit.rshift(r._to,24)),
          bit.band(0xff,bit.rshift(r._to,16)), bit.band(0xff,bit.rshift(r._to,8)), bit.band(0xff,bit.rshift(r._to,0)))
  
    return ff.." - "..ft
  end,
}

local Range  = { 
   new = function(from,to ) 
     return setmetatable(  {
        _from = from,
        _to = to,
      }, srange)
   end
} 

local bit=require 'bit' 
local IPRangeLookup   = {

  -- ip_range accepted 
  -- string "23.4.5.0/23" or "2.3.44.55" 
  -- 
  add = function( tbl, ip_range)
    local _,_, b1,b2,b3,b4,cidr = ip_range:find("(%d+)%.(%d+)%.(%d+)%.(%d+)/*(%d*)")
	if b1 == nil then return; end  
    local num_start = b1*math.pow(2,24) + b2*math.pow(2,16) + b3*math.pow(2,8) + b4*math.pow(2,0) 
    local num_end = num_start
    if #cidr > 0  then 
      num_end = num_start + math.pow(2, 32-tonumber(cidr)) -1 
    end
    tbl.lkp_table[#tbl.lkp_table+1] = Range.new( num_start, num_end)
  end, 


  -- returns lowerbound, upperbound
  -- 
  bin_search = function(tbl,  ip_key)
    local iStart,iEnd,iMid = 1,#tbl,0
    while iStart <= iEnd do
      iMid = math.floor( (iStart+iEnd)/2 )
      if ip_key == tbl [iMid]  then
        return tbl[iMid]
      elseif ip_key < tbl[iMid] then
        iEnd = iMid - 1
      else
        iStart = iMid + 1
      end
    end
    return nil  
  end,


  -- re-sort the entries 
  resort = function(tbl)
    table.sort(tbl.lkp_table)
  end, 


  -- lookup "82.188.23.12"
  -- 
  lookup = function(tbl, ip_dotted)
    local pmatch,_, b1,b2,b3,b4= ip_dotted:find("(%d+)%.(%d+)%.(%d+)%.(%d+)")
	if not pmatch then return nil ; end  
    local ipnum = b1*math.pow(2,24) + b2*math.pow(2,16) + b3*math.pow(2,8) + b4*math.pow(2,0) 
    local rcheck = Range.new(ipnum,ipnum)
    return tbl.bin_search(tbl.lkp_table, rcheck)
  end,

  -- lookup in trisul format C0.A8.23.FE 
  lookup_trisul = function(tbl, ip_trisul_key)
    local pmatch,_, b1,b2,b3,b4= ip_dotted:find("(%x+)%.(%x+)%.(%x+)%.(%x+)")
	if not pmatch then return nil ; end  
    local ipnum = tonumber(b1,16)*math.pow(2,24) + tonumber(b2,16)*math.pow(2,16) + tonumber(b3,16)*math.pow(2,8) + tonumber(b4,16)*math.pow(2,0) 
    local rcheck = Range.new(ipnum,ipnum)
    return tbl.bin_search(tbl.lkp_table, rcheck)
  end,

  check=function(tbl, ip_dotted)
  	return tbl.lookup(tbl,ip_dotted) ~= nil 
  end,

  -- loads a file containing 1 range per line 
  load = function(tbl, filename  )
    local f,err = io.open(filename)
    if f == nil then return false, err end 

    for l in f:lines() do 
      local  validline=true 
      if l:match("%s*#") then validline=false end 
      if validline then tbl.add(tbl, l) end 
    end 
    tbl.resort(tbl)
    return true 
  end,

  -- dump
  dump = function(tbl)
    for i,v in ipairs(tbl.lkp_table) do 
      print(v)
    end
  end,
}

-- metatbl - use a common mt (LuaJIT opt)
local smt = {
  __index = IPRangeLookup,

}

-- metatable 
local fh  = { 
  new = function( ) 
    return setmetatable(  {
      lkp_table = {} 
    }, smt)
  end
} 

return fh 

