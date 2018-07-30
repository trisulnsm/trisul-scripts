tris_leveldb.lua
==================

A LuaJIT wrapper to LevelDB. 

Specially designed to aid in fast lookups for network security applications.  We use this library in TrisulNSM in
some of our streaming analytics pipelines. For example,  to look up an IP to the DNS CNAME.


Features
--------

1. Speed - no fancy overhead, direct FFI into LevelDB C API
2. Most operations supported  including WriteBatch
3. Functions to get 'upper bound' and 'lower bound' used to locate closes lexicographic match 
4. Supports cloning a open database pointer (see end of this page) 


Test
------

To run the test suite.

````lua
$ luajit test.lua 
````

Usage
-------

Just pop the tris_leveldb.lua in your directory. 


### Basic usage


The following test code shows you to use the various functions. See `test.lua` 

````lua 


-- add this to your code 
local LDB=require'tris_leveldb'

-- create and open 
local db1 = LDB.new()
db1:open("/tmp/ip2loc.level")

-- put a few keys 
db1:put("k1","veeraTheDog")
db1:put("Longerkey with spaces ","Pakdam Pakdai")

-- get a few keys
print(db1:get("veeraTheDog"))

-- put a few keys at once (atomic) using LevelDB WriteBatch under the hood
db1:put_table( {
	k1   = "valu1",
	key2 = "value2",
	kkk5 = 10002,
	["What is this long key"] = "long key value"
} )

-- get 
print(db1:get("k1"))

-- close 
db1:close() 

````

#### Iterators 

````lua 

-- dump  full database 
-- demonstrates how to iterate 
local iter=db1:create_iterator()
iter:seek_to_first()
while iter:valid() do 
	local k,v = iter:key_value()
	print(k.."="..v)
	iter:iter_next()
end 
iter:destroy()


````

#### Search upper and lower bound 


If you want to search the database for upper and lower bound closest matches for a key.

````lua

-- test seekto  to get upper_bound match 
print("Test. seek_to()")
local iter=db1:create_iterator()
iter:seek_to("k10.0.0.12")
local k,v = iter:key_value()
if k and v  then print(k.."="..v) end
print('next')

iter:iter_next()
local k,v = iter:key_value()
if k and v  then print(k.."="..v) end
iter:destroy()


--  upper : matches the next lexicographically greater key 
local iter=db1:create_iterator()
local k,v = db1:upper(iter,"05.6E.20.00")
if k then 
	print(k.."="..v)
end 

````


## Passing database handle to clone


This is a unique feature of this library. Helps us a lot in streaming analytics.  The use case is the following.


> How to share a LevelDB database among different threads ? LevelDB does support multiple reader/writer 
> threads as long as they are in a single process. 


Using `toaddr(.._)` and `fromaddr(..)`  we can pass the handle around different threads. However only the _owner_ thread can close the database. Here is a snippet from test.lua


```lua 

--  the database opened , the db1 is called the Owner handle 
db1:open("/tmp/mytest1.level")


-- the copy db_copy is not the owner, but can use the database along with the owner 
-- even from a different Lua Host 
local db_copy  =  LDB.new()
local str = db1:toaddr()
db_copy:fromaddr(str)


-- writing from Owner handle db1 
db1:put("CLONE_TEST", "Hey this one is written from db1 (the owner)" )

-- reading from db_copy , it works 
print(db_copy:get("CLONED_TEST"))



-- ERROR!  db_copy:close() -- cant close handle from this object, 
                           -- will throw lua error. Only owner db1 can close it  

db1:close() 

```

