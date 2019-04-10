-- ftrie.lua
-- 
-- LuaJIT interface to ftrie GeoIP lookup 
-- 
-- Main use case : Used in Trisul Network Analytics LUA scripts   https://trisul.org
--
-- 
local ffi=require'ffi'
local L=ffi.load'./libftrie.so'

-- 
-- From LevelDB c.h API - we are only using a basic subset 
-- 
ffi.cdef [[
	typedef void 	GeoIP;

	GeoIP * 		GeoIP_open(const char * path, uint32_t flags);
	void			GeoIP_delete(GeoIP * pdb);
	bool 		    GeoIP_by_ipnum(GeoIP * GeoIP_Handle, uint32_t ipnum, const char ** key, const char ** label);
	bool 		    GeoIP_by_key(GeoIP * GeoIP_Handle, const char * ipkey, const char ** key, const char ** label);
	bool 		    GeoIP_by_ipaddr(GeoIP * GeoIP_Handle, const char * dotted, const char ** key, const char ** label);

]]

local sftrie = {

  -- return true or false,errmsg 
  open=function(tbl, dbpath)

  		local db = L.GeoIP_open(dbpath, 0);
		if db then
			tbl._db=db
			return true, db
		else
			tbl.db=nil
			return false, "error opening db"
		end
  end,

  -- key in trisul format 
  lookup_key=function(tbl, ipv4_key)
	local ret=L.GeoIP_by_key( tbl._db, ipv4_key, tbl._kbuf, tbl._lbuf);
	if ret  then
		return ffi.string(tbl._kbuf[0]),ffi.string(tbl._lbuf[0])
	else
		return nil
	end
  end,

  -- key in ipv4 dotted
  lookup_dotted=function(tbl, ipv4_dotted)
	local ret=L.GeoIP_by_ipaddr( tbl._db, ipv4_dotted, tbl._kbuf, tbl._lbuf);
	if ret  then
		return ffi.string(tbl._kbuf[0]),ffi.string(tbl._lbuf[0])
	else
		return nil
	end

  end,

  -- done 
  close=function(tbl)
  	L.GeoIP_delete(tbl._db)
  end
}

local FTrie    = { 
  new = function( ) 
    return setmetatable(  {
      _db = nil ,
      errmsg=nil,
	  _kbuf=ffi.new("const char*[1]"),
	  _lbuf=ffi.new("const char*[1]"),
    }, { __index = sftrie} )
  end
} 

return FTrie 

