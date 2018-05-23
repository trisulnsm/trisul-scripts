ipprefix db 
==================

A library that does prefix matching over a very large dataset using LevelDB backend. 

Can be used for applications in routing, network security . 

Features
----

1. Fast
2. Easy
3. Low memory use (considering 2GB limit in LuaJIT) 
4. Designed to support millions of prefixes 
4. Supports multiple databases 


Pre-requisities
-----

You must have LevelDB installed on your system , we're looking for `libleveldb.so` somewhere in your library search path. 

## Usage

````lua 
local IPPrefixDB=require'ipprefixdb'


-- create and open 
local db1 = IPPrefixDB.new()
db1:open("/tmp/ipdb.level")


-- store 

db1:put("192.168.0.0/16", "192 network private") 
db1:put("192.168.4.0/8",  "Video servers 4/8") 
db1:put(16802560,16802815, "Using IP 32 bit numbers ")
db1:put("C0.A8.01.01","C0.A8.01.FF", "Using trisul keys 1.1 ")
db1:put("192.168.4.18","192.168.4.22", "Using dotted IP without even a proper subnet ")


-- get 
print ( db1:get("192.168.4.19") )
print ( db1:get("18.82.8.82") )
print ( db1:get("18.82.8.82") )
print ( db1:get("A8.83.8F.FA")  )
print ( db1:get(8834882)  )


-- dump
db1:dump()

-- closing 
db1:close()

````

## Query tool

Use the `querytool.lua` script to query the database 


Usage 
````lua
luajit querytools.lua  <database-path>  [optional-database-prefix] <IP Address>
````

Examples 



