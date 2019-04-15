# Blacklist 

Uses the Trisul Lua `onnewkey` API method to very efficiently check for blacklisted keys from any counter group.


##  Shadowhammer

The mac.lua script shows how you can trigger a real time alert whenever a MAC address from the [Operation ShadowHammer attack](https://securelist.com/operation-shadowhammer/89992/)  shows up.


The `onnewkey` method  from the Trisul LUA Script API](https://trisul.org/docs/lua/cg_monitor.html#function_onnewkey) is used to check for newly seen keys. 
Behind the scenes Trisul uses a efficient first-seen algorithm to dramatically reduce the frequency of this method. 
Hence this has negligible CPU usage requirements.


## Adapt

You can adapt this to check any counter group key,  IP addresses,  HTTP Host names, TLS SNI, Cipher suits, MAC addresses, Countries, ASN, etc. 
All you have to do is replace the GUID in 


````lua

    counter_guid = "<INSERT GUID OF THE COUNTER GROUP TO BE MONITORED>"

````



