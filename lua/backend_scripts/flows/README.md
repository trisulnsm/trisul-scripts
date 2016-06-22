# Backend Scripts - Flows

These scripts demonstrates working with flows on the metrics backend.

## Index of scripts 


Filename             |                    What it does                  | Demonstrates 
---------------------|--------------------------------------------------|----------------------------
sg1.lua  | Prints all new flow keys to the console | Minimal script demonstrates usage of onnewflow
sg2.lua  | Write files -  one per backend instance - and prints flow details into it | Work with multiple instances of script, file io, global variables
sg3.lua  | Working example - prints flow details like sourceip,port,destip,total bytes, interval | Navigating flow object model, writing to files, using string and time formatting | 



## Running

Place these scripts in these locations and restart trisul-probe . Normally you want to do the first (local-lua) when testing. 


Node | Directory | Remarks |
-----|-----------|---------|
On Probe | Dir /usr/local/var/lib/trisul/domain0/probe0/context0/config/local-lua   | local-lua scripts apply to that probe and context only. Normally you want to do this when experimenting
On Probe | Dir /usr/local/lib/trisul-probe/plugins/lua | Script loaded for all instances on that node (machine) |
On Hub | Dir /usr/local/lib/trisul-hub/domain0/hub0/profileX/lua | All probes that use that profileX will get the lua script |


2. /usr/local/
