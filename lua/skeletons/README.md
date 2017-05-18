Skeleton selector
===========


Trisul LUA API documentation at https://trisul.org/docs/lua


What do I want to do ? Listen to .. |Use this skeleton 
---|---
every packet at a given protocol layer |  simple_counter.lua 
each TCP reassembled segment | reassembly_handler.lua 
each HTTP URI, header, TLS certificate, etc | reassembly_handler.lua 
read a custom PCAP file or Flow file as input to Trisul |  input_filter.lua
listen to alerts from custom sources and feed into Trisul pipeline |  input_filter.lua 
a custom network protocol not supported by Trisul  | protocol_handler.lua 
control PCAP storage on a per-flow basis | packet_storage.lua  
HTTP file extraction | filex_monitor.lua     
create a new counter group | new_counter_group.lua 
create a new alert group | new_alert_group.lua 
create a new resource group | new_resource_group.lua 
when a streaming window is opened, closed | engine_monitor.lua 
each new alert . Eg IDS alert, Flow Tracker, etc | alert_monitor.lua 
each new resource. Eg DNS, SSL Cert, HTTP URI, etc| resource_monitor.lua 
each new Full Text Document. Full DNS , SSL, HTTP Headers | fts_monitor.lua 
when a counter (metric) is updated,  | cg_monitor.lua 
when a topper list is flushed to storage   | cg_monitor.lua 
when a new key is first seen in a counter group| cg_monitor.lua 
a new flow is seen | sg_monitor.lua  
when flows are flushed to storage| sg_monitor.lua  
create your own flow tracker | flow_tracker.lua  |

Common facilities available to all backend scripts  

1. `onmetronome` to get called every second (approx)
2. `flushfilter` to decide is a particular object gets flushed to database or not 
3. `beginflush` and `endflush` to indicate the closing of a streaming Time Window 
 

