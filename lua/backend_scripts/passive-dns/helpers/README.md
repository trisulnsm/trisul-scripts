Minimal LUAJIT interface to LevelDB 
================================

A fast and minimal LUAJIT interface to LevelDB. 

```lua
local LDB=require'tris_leveldb'

local writer,reader,closer  = LDB.from_addr(LDB.open("mydatabase.ldb"))

writer("key1","foobar")
print( reader("key1"))
closer()

LDB.dump("mydatabase.ldb") 

```

Supports the following 

1. opening and closing 
2. put 
3. get
4. delete
5. print the entire DB 


There are a number of other Lua LevelDB wrappers out there, but we had some very specific requirements.

1. concurrent reads - one worker opened a DB and others shared that DB for read/write
2. closure (upvalue) based API 
3. had to be LuaJIT - that is what we embed in Trisul 


Requirements
------------

Install leveldb. The `libleveldb.so`  shared library is required for this to work. 
We use LUAJIT FFI to enter the shared library.


Usage
-----
This API allows you do the following 

Worker 0

```lua

local LDB=require'tris_leveldb'

local dbstr  = LDB.open("mydatabase.ldb")

Broadcast(dbstr) -- send this to various workers (filters) in Trisul stream 

local writer,reader  = LDB.from_addr(dbstr);

writer("key1","foobar")
print( "key 1 is ".. reader("key1"))

```

Worker 1

```lua

OnMessage( dbstr)  -- received a leveldb handle 


local writer,reader  = LDB.from_addr(dbstr);

print( "key 1 is ".. reader("key1"))

```



test1.lua
---------

A simple test script showing the API usage 

