-- tris_leveldb.lua
-- 
-- Very basic levelDB wrapper using LUAJIT FFI to access the LevelDB C API
-- 
-- Used in Trisul Network Analytics Passive DNS 
--
-- 
local ffi=require'ffi'
local L=ffi.load'./libleveldb.so'


-- 
-- From LevelDB c.h API - we are only using a basic subset 
-- 
ffi.cdef [[

typedef struct leveldb_t               leveldb_t;
typedef struct leveldb_options_t       leveldb_options_t;
typedef struct leveldb_writeoptions_t  leveldb_writeoptions_t;
typedef struct leveldb_readoptions_t   leveldb_readoptions_t;
typedef struct leveldb_iterator_t      leveldb_iterator_t;

/* DB operations */

leveldb_t* leveldb_open(
    const leveldb_options_t* options,
    const char* name,
    char** errptr);

void leveldb_close(leveldb_t* db);

void leveldb_put(
    leveldb_t* db,
    const leveldb_writeoptions_t* options,
    const char* key, size_t keylen,
    const char* val, size_t vallen,
    char** errptr);

char* leveldb_get(
    leveldb_t* db,
    const leveldb_readoptions_t* options,
    const char* key, size_t keylen,
    size_t* vallen,
    char** errptr);

leveldb_iterator_t* leveldb_create_iterator(
    leveldb_t* db,
    const leveldb_readoptions_t* options);


void leveldb_delete(
    leveldb_t* db,
    const leveldb_writeoptions_t* options,
    const char* key, size_t keylen,
    char** errptr);

void leveldb_iter_destroy(leveldb_iterator_t*);
unsigned char leveldb_iter_valid(const leveldb_iterator_t*);
void leveldb_iter_seek_to_first(leveldb_iterator_t*);
extern void leveldb_iter_next(leveldb_iterator_t*);
void leveldb_iter_prev(leveldb_iterator_t*);
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
unsigned long long int strtoull(const char *nptr, char **endptr,
                                       int base);


]]

local tris_leveldb = {}


-- rather than use typical metatables, this approach set the DB as upvalue and uses closures
-- open method, returns two Closures,  writerfn and readerfn
-- 


--
-- dump : dump all keys and values 
-- used to debug 
tris_leveldb.dump = function(database_path)

	local errmsg = ffi.new(' char *[1]') 
	local db_opts  = L.leveldb_options_create();

	local db = L.leveldb_open(db_opts,   database_path  , errmsg)
	if db == nil    then
		print('Error opening leveldb database'..ffi.string(errmsg[0])  )
		return  nil, ffi.string(errmsg[0])
	end


	local readlen = ffi.new(' size_t  [1]') 
	local read_db_opts  = L.leveldb_readoptions_create();
	local iter = L.leveldb_create_iterator( db, read_db_opts);
	L.leveldb_iter_seek_to_first(iter)
	while L.leveldb_iter_valid(iter) == 1 do

			local k = L.leveldb_iter_key( iter, readlen);
			local ks = ffi.string(k,readlen[0]);

			local v = L.leveldb_iter_value( iter, readlen);
			local vs = ffi.string(v,readlen[0]);

			print(ks.." "..vs)

			L.leveldb_iter_next(iter)
	end 

	L.leveldb_iter_destroy(iter)
	L.leveldb_close(db)

	print("Done")

end


--
-- open : casts a leveldb_t pointer into a Hex String and use that to initialize the DB using
--		  from_addr(..) function 
--        
tris_leveldb.open = function( database_path )

	local errmsg = ffi.new(' char *[1]') 
	local db_opts  = L.leveldb_options_create();
	L.leveldb_options_set_create_if_missing( db_opts, 1 );

	local db = L.leveldb_open(db_opts,   database_path  , errmsg)
	if db == nil    then
		print('Error creating leveldb database'..ffi.string(errmsg[0])  )
		return  nil, ffi.string(errmsg[0])
	end
	return string.format("%X",tonumber(ffi.cast("intptr_t",db)));
end

--
-- from_addr : dbaddr is a string 8837748898FD that represents a leveldb_t * pointer
--             constructed elsewhere. 
-- 
-- return : Writer,Reader,Closer - three closures 
-- 
tris_leveldb.from_addr  = function( dbaddr)

	local dbaddr_i = ffi.C.strtoull(dbaddr,nil,16)
	-- print("opening  database at address "..tostring(dbaddr_i))
	local db = ffi.cast( "leveldb_t*", dbaddr_i  )

	-- close writer function 
	local writefn_up = function()

		local _db = db; -- upvalue 
		local write_opts  = L.leveldb_writeoptions_create();
		local errmsg = ffi.new(' char *[1]') 

		-- true if success, false , errmsg otherwise 
		return function(k,v)
			L.leveldb_put( db, write_opts, k,#k, v, #v, errmsg)
			if errmsg[0] == nil then
				return true, ""
			else
				local emsg = ffi.string(errmsg[0]);
				L.leveldb_free( errmsg[0] ) 
				return false, emsg
			end
		end 
	end

	-- close reader fun 
	local readfn_up = function()

		local _db = db; -- upvalue 
		local read_opts  = L.leveldb_readoptions_create();
		local errmsg = ffi.new(' char *[1]') 
		local readlen = ffi.new(' size_t  [1]') 

		-- value or nil
		return function(k,v)
			local val = L.leveldb_get( _db, read_opts, k, #k, readlen, errmsg);
			if val == nil  then 
				return nil 
			else 
				return ffi.string(val,readlen[0])
			end 
		end 

	end

	-- delete reader fun 
	local deletefn_up = function()

		local _db = db; -- upvalue 
		local write_opts  = L.leveldb_writeoptions_create();
		local errmsg = ffi.new(' char *[1]') 

		-- delete a k
		return function(k)
			L.leveldb_delete( db, write_opts, k,#k ,errmsg)
			if errmsg[0] == nil then
				return true
			else
				local emsg = ffi.string(errmsg[0]);
				L.leveldb_free( errmsg[0] ) 
				return false, emsg
			end
		end 
	end


	-- closer 
	local closerfn_up = function()

		local _db = db; -- upvalue 

		-- value or nil
		return function()
			L.leveldb_close(_db);
		end 

	end

	return writefn_up(), readfn_up(),closerfn_up() ,deletefn_up() 

end


return tris_leveldb

