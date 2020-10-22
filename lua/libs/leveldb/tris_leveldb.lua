-- tris_leveldb2.lua
-- 
-- Very basic levelDB wrapper using LUAJIT FFI to access the LevelDB C API
-- 
-- Used in Trisul Network Analytics LUA scripts 
--
-- 
local ffi=require'ffi'
local L=ffi.load'libleveldb.so.1'

-- 
-- From LevelDB c.h API - we are only using a basic subset 
-- 
ffi.cdef [[

typedef struct leveldb_t               leveldb_t;
typedef struct leveldb_options_t       leveldb_options_t;
typedef struct leveldb_writeoptions_t  leveldb_writeoptions_t;
typedef struct leveldb_readoptions_t   leveldb_readoptions_t;
typedef struct leveldb_iterator_t      leveldb_iterator_t;
typedef struct leveldb_writebatch_t    leveldb_writebatch_t;

/* FFI defs lifted straight from LevelDB C API c.h */

leveldb_t* leveldb_open(const leveldb_options_t* options,const char* name,char** errptr);

void leveldb_close(leveldb_t* db);

void leveldb_put(leveldb_t* db,const leveldb_writeoptions_t* options,const char* key, size_t keylen,
    const char* val, size_t vallen,char** errptr);

char* leveldb_get(leveldb_t* db,const leveldb_readoptions_t* options,const char* key, size_t keylen,
    size_t* vallen,char** errptr);

leveldb_iterator_t* leveldb_create_iterator(leveldb_t* db,const leveldb_readoptions_t* options);
void leveldb_delete(leveldb_t* db,const leveldb_writeoptions_t* options,const char* key, size_t keylen,char** errptr);
void leveldb_iter_destroy(leveldb_iterator_t*);
unsigned char leveldb_iter_valid(const leveldb_iterator_t*);
void leveldb_iter_seek_to_first(leveldb_iterator_t*);
void leveldb_iter_next(leveldb_iterator_t*);
void leveldb_iter_prev(leveldb_iterator_t*);
void leveldb_iter_seek(leveldb_iterator_t*,const char* k, size_t klen);
const char* leveldb_iter_key(const leveldb_iterator_t*, size_t* klen);
const char* leveldb_iter_value(const leveldb_iterator_t*, size_t* vlen);
leveldb_options_t* leveldb_options_create();
void leveldb_options_destroy(leveldb_options_t*);
void leveldb_options_set_create_if_missing( leveldb_options_t*, unsigned char);
void leveldb_options_set_error_if_exists( leveldb_options_t*, unsigned char);
void leveldb_options_set_paranoid_checks( leveldb_options_t*, unsigned char);
void leveldb_free(void* ptr);
leveldb_writeoptions_t* leveldb_writeoptions_create();
void leveldb_writeoptions_destroy(leveldb_writeoptions_t*);
leveldb_readoptions_t* leveldb_readoptions_create();
void leveldb_readoptions_destroy(leveldb_readoptions_t*);
unsigned long long int strtoull(const char *nptr, char **endptr,int base);
leveldb_writebatch_t* leveldb_writebatch_create();
void leveldb_writebatch_destroy(leveldb_writebatch_t*);
void leveldb_writebatch_put(leveldb_writebatch_t*,const char* key, size_t klen,const char* val, size_t vlen);
void leveldb_write(leveldb_t* db,const leveldb_writeoptions_t* options,leveldb_writebatch_t* batch, char** errptr);

]]

local siterator = {

  create=function(ldb)
    local read_db_opts  = L.leveldb_readoptions_create();
    return L.leveldb_create_iterator(ldb,  read_db_opts)
  end, 

  seek_to_first=function(tbl)
    L.leveldb_iter_seek_to_first(tbl._iter)
  end,

  seek_to=function(tbl,key)
    L.leveldb_iter_seek(tbl._iter,key,#key)
  end,

  iter_next=function(tbl)
    L.leveldb_iter_next(tbl._iter)
  end,
  
  iter_prev=function(tbl)
    L.leveldb_iter_prev(tbl._iter)
  end,

  destroy=function(tbl)
    L.leveldb_iter_destroy(tbl._iter)
  end,

  valid=function(tbl)
    return L.leveldb_iter_valid(tbl._iter)==1
  end,

  key_value=function(tbl)
    if tbl:valid() then
      local readlen = ffi.new(' size_t  [1]') 
      local v = L.leveldb_iter_value( tbl._iter, readlen);
      local vs =  ffi.string(v,readlen[0]);
      local k = L.leveldb_iter_key( tbl._iter, readlen);
      local ks =  ffi.string(k,readlen[0]);
      return ks,vs
    else
      return nil
    end 
  end,
}

local Iterator  = { 
   new = function(ldb) 
     return setmetatable(  {
        _iter = siterator.create(ldb),
      }, { __index=siterator})
   end
} 


local sleveldb = {

  -- return true or false,errmsg 
  open=function(tbl, dbpath)

    local errmsg = ffi.new(' char *[1]') 
    local db_opts  = L.leveldb_options_create();
    L.leveldb_options_set_create_if_missing( db_opts, 1 );

    tbl._db = L.leveldb_open(db_opts,   dbpath  , errmsg)
    if tbl._db == nil    then
      print('Error opening leveldb database'..ffi.string(errmsg[0])  )
      return  false, ffi.string(errmsg[0])
    end

    -- vars used everywhere  
    tbl.errmsg = ffi.new(' char *[1]') 
    tbl.read_opts  = L.leveldb_readoptions_create();
    tbl.write_opts  = L.leveldb_writeoptions_create();
	  tbl.owner=true

    return true
  end,

  -- toaddr : used to share open database pointers using Trisul messaging  
  toaddr=function(tbl)
  	if not tbl.owner then
		  error("Cannot to toaddr() from databases that do not own the _db pointer")
		  return
    end 
    return string.format("%X",tonumber(ffi.cast("intptr_t",tbl._db)));
  end,

  -- fromaddr : used to share open database pointers using Trisul messaging  
  fromaddr=function(tbl,dbaddr)
    local dbaddr_i = ffi.C.strtoull(dbaddr,nil,16)
    tbl._db = ffi.cast( "leveldb_t*", dbaddr_i  )
    tbl.errmsg = ffi.new(' char *[1]') 
    tbl.read_opts  = L.leveldb_readoptions_create();
    tbl.write_opts  = L.leveldb_writeoptions_create();
    tbl.owner=false
    return true
  end, 

  -- close 
  close=function(tbl)
  	if not tbl.owner then
		  error("Cannot close() leveldb database when  you are not an owner. Did you use fromaddr() to create it ?")
		  return
    end
    L.leveldb_close(tbl._db)
    tbl._db=nil 
  end, 


  -- get key,val 
  -- get a k,value with a k
  get=function(tbl,k)
    local readlen = ffi.new(' size_t  [1]') 
    local val = L.leveldb_get( tbl._db, tbl.read_opts, k, #k, readlen, tbl.errmsg);
    if val == nil  then 
      return nil 
    else 
      return k,ffi.string(val,readlen[0])
    end 
  end,

  -- getval
  getval=function(tbl,k)
    local readlen = ffi.new(' size_t  [1]') 
    local val = L.leveldb_get( tbl._db, tbl.read_opts, k, #k, readlen, tbl.errmsg);
    if val == nil  then 
      return nil 
    else 
      return ffi.string(val,readlen[0])
    end 
  end,



  -- put a KV 
  put=function(tbl,k,v)

    L.leveldb_put( tbl._db, tbl.write_opts, k,#k, v, #v, tbl.errmsg)
    if tbl.errmsg[0] == nil then
      return true, ""
    else
      local emsg = ffi.string(tbl.errmsg[0]);
      L.leveldb_free( tbl.errmsg[0] ) 
      return false, emsg
    end

  end,

  -- put bulk
  -- uses writeBatch to write out the table (k,v) 
  put_table=function(tbl, keyval_table) 

  	local wbatch = L.leveldb_writebatch_create()

  	for k,v in pairs(keyval_table)
  	do 
  		local ks= tostring(k)
  		local vs= tostring(v) 
  		L.leveldb_writebatch_put( wbatch, ks,#ks,vs,#vs)
  	end 

    L.leveldb_write( tbl._db, tbl.write_opts, wbatch,  tbl.errmsg)
    L.leveldb_writebatch_destroy(wbatch)

    if tbl.errmsg[0] ~= nil  
    then 
      local emsg = ffi.string(tbl.errmsg[0]);
      L.leveldb_free( tbl.errmsg[0] ) 
      print(emsg) 
      return false, emsg
    end
  end, 

  -- delete a key 
  delete=function(tbl,k)
    L.leveldb_delete( tbl._db, tbl.write_opts, k,#k ,tbl.errmsg)
    if tbl.errmsg[0] == nil then
      return true
    else
      local emsg = ffi.string(tbl.errmsg[0]);
      L.leveldb_free( tbl.errmsg[0] ) 
      return false, emsg
    end
  end,
  
  -- iterator 
  create_iterator=function(tbl)
    return Iterator.new(tbl._db)
  end,

  -- get keys lexicographically above and below the key
  -- return k0,v0,k1,v1  - if exact match, k0,v0,k0,v0
  -- nils if invalid 
  get_bounds=function(tbl,iterator, key)

      iterator:seek_to(key)
      if not iterator:valid()  then return nil end 

      local k0,v0 = iterator:key_value()
      if k0==key then 
        return k0,v0,k0,v0
      end

      iterator:iter_prev()
      if not iterator:valid()  then return nil end 
      local k1,v1 = iterator:key_value()
      return k0,v0,k1,v1
  end,

  -- upper match
  -- 
  upper=function(tbl,iterator,key,fn_match)
    iterator:seek_to(key)
    if not iterator:valid()  then return nil end 

    local k0,v0 = iterator:key_value()

  	if fn_match == nil or fn_match(k0,key) then 
  		return k0,v0
  	else
  		iterator:iter_prev()
  		if not iterator:valid()  then return nil end 
  		return iterator:key_value()
  	end
  end,

  -- lower match
  --
  lower=function(tbl,iterator,key, fn_match)
    iterator:seek_to(key)
    if not iterator:valid()  then return nil end 

    local k0,v0 = iterator:key_value()

  	if fn_match == nil or fn_match(k0,key) then 
  		return k0,v0
  	else
  		iterator:iter_next()
  		if not iterator:valid()  then return nil end 
  		return iterator:key_value()
  	end
  end,

  -- dump the whole database 
  dump=function(tbl)

    print("----Dumping----")
    local iter=tbl.create_iterator(tbl)
    iter:seek_to_first()
    while iter:valid() do 
      local k,v = iter:key_value()
      print(k.."="..v)
      iter:iter_next()
    end 
    iter:destroy()
    print("End----")

  end
}

local LevelDB   = { 
  new = function( ) 
    return setmetatable(  {
      _db = nil ,
      write_opts=nil,
      read_opts=nil,
      errmsg=nil,
      owner=true,
    }, { __index = sleveldb} )
  end
} 

return LevelDB 

