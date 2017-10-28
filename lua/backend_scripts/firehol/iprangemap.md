LUA IP range  lookup
===================

iprangemap.lua is a simple fast lookup library to check an IP address against a database of 
IP ranges to check if there is match. 

We at Trisul Network Analytics are using this for checking an IP against blacklists. 


Usage
-----

The following snippet creates a new map, adds 3 subnets, then checks and prints any matching ranges

````lua 
local RMAP=require'iprangemap'

local rm = RMAP.new()
rm:add("103.229.217.0/24")
rm:add("74.207.22..122")	-- bad form , will be rejected 
rm:add("29.212.22..0/255")
rm:add("23.251.224.0/19")

rm:resort() -- not needed if you add in sorted order

rm:dump()

-- check(ip) true or false
print(rm:check("103.229.217.2") ) -- prints true
print(rm:check("10.29.7.2"))      -- prints false

-- print matching range 
local match = rm:lookup("23.251.224.4")
print("Found match=".. tostring(match))

````



Examples
--------

Check how we use this to check the FireHOL ranges in `firehol.lua` 
