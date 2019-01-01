# mrumap : pure lua lookup table with O(1) LRU prune 

A map backed by a MRU list that allows you to prune the least recently used keys in O(1) 


## Motivation 

A very common pattern in Trisul network scripting is to store a per-flow state. This is usually done by 
means of a normal MAP with a string FLOWKEY. 

```
flowlookup[flowkey] = { packet_count = 88, 
						last_seen_id = 77,
						.. }
```

Now the issue is handling the maintenance of this table. Since,  we are dealing with a network scripting framework
like Trisul, we cant be sure of getting the 'cleanup' signal or in the case of case of UDP or ICMP flows, there is no 'cleanup' signal.  
						
One common solution is to record the "last seen action" for each flow. Then periodically sweep the table and throw out
old items say over 2 minutes old.  This works, but the sweep operation is O(N) will stall the fast path for large tables. 

In Trisul we try to do better.

> This mrumap table guarantees a O(1) removal of the Least Recently Used (LRU) item. 


## Use cases

* Lookup table to hold state per-flow.  

## Usage


Also see test.lua 

### Creating the map 

in your LUA code do the following


```lua

local MM=require('mrumap')

mmflows = MM.new(1000)   -- map with a max capacity of 1000 (default 100)
```


### looking up

use the get method

````
local state=mmflows:get("aflowid") 
````

### inserting

the put method
````
local state=mmflows:get("aflowid") 
if state==nil then
	mmflows:put("aflowid", { sequence=1, 
		                    mystate=2,..} 
			   )
end 
````

Thats it !! if the map grows beyond the capacity, then the LRU item is automatically popped to make way for new entries. 



## Advanced usage

You can manually control the LRU by the `pop_lru()` method. Just set the capacity to -1 


````lua 
local MM=require('mrumap')

mmflows = MM.new()  -- no capacity set  

mmflows:put("First item" , "Hi this is the state" ) 
mmflows:put("Second item" , "the state 2 ", 154233455)  -- with an optional insert timestamp 

if mmflows:size() > 100 then 
	local v,t = mmflows:pop_lru()
	print("Popped item that was crated on ".. t )
end 

````

