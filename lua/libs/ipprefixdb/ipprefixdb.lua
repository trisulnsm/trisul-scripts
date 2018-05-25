--
-- ipprefixdb.lua
-- 
-- 
local leveldb=require'tris_leveldb' 
local bit=require'bit'
local IP6=require'ip6'

-- ip number to trisulkey format
function ipnum_tokey(ipnum)
	return string.format("%02X.%02X.%02X.%02X", 
		bit.rshift(ipnum,24), bit.band(bit.rshift(ipnum,16),0xff), bit.band(bit.rshift(ipnum,8),0xff), bit.band(bit.rshift(ipnum,0),0xff))
end
function key_toipnum(key)
  local pmatch,_, b1,b2,b3,b4= key:find("(%x+)%.(%x+)%.(%x+)%.(%x+)")
  return  tonumber(b1,16)*16777216+tonumber(b2,16)*65536+tonumber(b3,16)*256+tonumber(b4,16) 
end
function ip6_tokey(num)

end
function key_toip6(ip6key)

end

local ipprefixdb   = {

  -- put functions
  -- 
  put=function(tbl, ipnum_from, ipnum_to, val)
	tbl.ldb:put(tbl.ldb_keyprefix.."FWD/".. ipnum_tokey(ipnum_from).."-"..ipnum_tokey(ipnum_to).."/"..(ipnum_to-ipnum_from+1), val)
	tbl.ldb:put(tbl.ldb_keyprefix.."REV/".. ipnum_tokey(ipnum_to).."-"..ipnum_tokey(ipnum_from).."/"..(ipnum_to-ipnum_from+1), val)
  end, 

  put_cidr = function( tbl, ip_range, val )
    local _,_, b1,b2,b3,b4,cidr = ip_range:find("(%d+)%.(%d+)%.(%d+)%.(%d+)/*(%d*)")
	if b1 == nil then return; end  
    local num_start = b1*math.pow(2,24) + b2*math.pow(2,16) + b3*math.pow(2,8) + b4*math.pow(2,0) 
    local num_end = num_start
    if #cidr > 0  then 
      num_end = num_start + math.pow(2, 32-tonumber(cidr)) -1 
    end
	tbl.put(tbl, num_start, num_end, val) 
  end, 

  put_ipv6_cidr = function( tbl, ipv6, val )
    local _,_,ip ,cidr = ipv6:find("([%x:]*)/(%d*)")
	local f,l = IP6.ip6_cidr(ip,cidr)
	tbl.ldb:put(tbl.ldb_keyprefix.."FWD/".. f.."-"..l.."/"..cidr, tostring(val))
	tbl.ldb:put(tbl.ldb_keyprefix.."REV/".. l.."-"..f.."/"..cidr, tostring(val))
  end,

  put_ipnum = function( tbl, ipnum_from, ipnum_to, val )
  	tbl.put(tbl,ipnum_from, ipnum_to, val)
  end,

  put_trisul_key = function( tbl, key_from, key_to, val )
    local range = key_toipnum(key_to) - key_toipnum(key_from) + 1
	tbl.ldb:put( tbl.ldb_keyprefix.."FWD/"..key_from.."-"..key_to.."/"..range, val)
	tbl.ldb:put( tbl.ldb_keyprefix.."REV/"..key_to.."-"..key_from.."/"..range, val)
  end,

  put_dotted_ip = function( tbl, ip_dotted_from, ip_dotted_to, val )
    local pmatch,_, b1,b2,b3,b4= ip_dotted_from:find("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    if not pmatch then return nil ; end
    local pmatch,_, c1,c2,c3,c4= ip_dotted_to:find("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    if not pmatch then return nil ; end
	return tbl.put_trisul_key(tbl, 
							  string.format("%02X.%02X.%02X.%02X", b1,b2,b3,b4),
							  string.format("%02X.%02X.%02X.%02X", c1,c2,c3,c4), val )
  end,

  range_match=function(dbkey, keyin)
	local dir,k1,k2,range = dbkey:match("|(%w+)/([%x%.]+)-([%x%.]+)/(%d+)")
	local key=keyin:match("/(.*)$")
	if dir=="REV" and key <= k1 and key >= k2 then
		return true
	elseif dir=="FWD" and key >=k1 and key <=k2 then
		return true
	else
		return false
	end
  end, 

  lookup_prefix_fwd = function(tbl,key)
  	local iter = tbl.ldb:create_iterator()
    local k0,v0= tbl.ldb:upper(iter, tbl.ldb_keyprefix.."FWD/"..key,tbl.range_match)
	iter:destroy()
    if k0 then
        local k1,k2,range = k0:match("FWD/([%x%.]+)-([%x%.]+)/(%d+)")
        if key <= k2 and key >= k1 then
            return v0,tonumber(range)
        end
    end
  end,


  lookup_prefix_rev = function(tbl,key)
  	local iter = tbl.ldb:create_iterator()
    local k0,v0= tbl.ldb:lower(iter, tbl.ldb_keyprefix.."REV/"..key, tbl.range_match )
	iter:destroy()
    if k0 then
        local k1,k2,range = k0:match("REV/([%x%.]+)-([%x%.]+)/(%d+)")
        if key <= k1 and key >= k2 then
            return v0,tonumber(range)
        end
    end
  end,
  
  lookup_prefix= function(tbl,key)
  	local vf,frange=tbl.lookup_prefix_fwd(tbl,key) 
	local vr,rrange=tbl.lookup_prefix_rev(tbl,key)
	if vf and vr then 
		if frange<rrange then return vf else return vr end 
	else
		return vf or vr
	end 
  end,


  -- get functions 
  -- 
  get_trisul_key =function(tbl, ip_trisul_key)
     local val = tbl.lookup_prefix(tbl,ip_trisul_key)
	 return val
  end,


  -- lookup "82.188.23.12"
  -- 
  get_dotted_ip=function(tbl, ip_dotted)
    local pmatch,_, b1,b2,b3,b4= ip_dotted:find("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    if not pmatch then return nil ; end
	return tbl.get_trisul_key(tbl, string.format("%02X.%02X.%02X.%02X", b1,b2,b3,b4))
  end,

  -- lookup 337884899
  -- 
  get_ipnum=function(tbl, ipnum)
	return tbl.get_trisul_key(tbl,ipnum_tokey(ipnum))
  end, 

  -- open filename
  open=function(tbl, dbpath, readonly_flag)

  	local readonly = readonly_flag or false 
	tbl.ldb = leveldb.new()
    local f,err=tbl.ldb:open(dbpath, readonly)
	if not f then
		return f, err 
	end
	tbl.ldb_iterator=tbl.ldb:create_iterator()

	tbl.set_databasename(tbl,"0")
  end,

  -- set databasename 
  set_databasename=function(tbl, dbname)
  	tbl.ldb_keyprefix=dbname.."|"
	tbl.ldb:put(tbl.ldb_keyprefix.."FWD/FF.FF.FF.FF-FF.FF.FF.FF/1", "last" ) 
	tbl.ldb:put(tbl.ldb_keyprefix.."REV/FF.FF.FF.FF-FF.FF.FF.FF/1", "last" ) 
	tbl.ldb:put(tbl.ldb_keyprefix.."FWD/00.00.00.00-00.00.00.00/1", "first" ) 
	tbl.ldb:put(tbl.ldb_keyprefix.."REV/00.00.00.00-00.00.00.00/1", "first" ) 
  end,

  -- close 
  close=function(tbl)
      if tbl.ldb_iterator then tbl.ldb_iterator:destroy()  end
	  if tbl.ldb then tbl.ldb:close()  end
  end,

  -- dump
  dump=function(tbl)
	  tbl.ldb:dump()
  end,

  -- putraw
  -- pass thru to level db
  putraw=function(tbl,key,val)
  	tbl.ldb:put("ZZZZ"..key,val)
  end,

  getraw=function(tbl,key)
  	return tbl.ldb:get("ZZZZ"..key)
  end


}

local IPPrefixDB   = {
  new = function( )
      return setmetatable(  {
	        ldb=nil ,
			ldb_iterator=nil,
			ldb_keyprefix="0|",
	 }, { __index = ipprefixdb} )
  end
}

return IPPrefixDB


