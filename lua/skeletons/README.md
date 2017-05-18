Skeleton selector
===========


1 Frontend scripts work on Packet Stream (fast path)
2 Backend scripts work on Analytics Stream  (slow path)


these operate on fast path. Front end scripts


What do I want to do ? Listen to .. |  Script type 
--------------------  | ------------ | ------------ 
every packet at a given protocol layer |  simple_counter 
each TCP reassembled segment | reassembly_handler  
each HTTP URI, header, TLS certificate, etc | reassembly_handler | https://www.trisul.org/docs/lua/reassembly.html 
read a custom PCAP file or Flow file as input to Trisul |  input_filter 
listen to alerts from custom sources and feed into Trisul pipeline |  input_filter 
a custom protocol not supported by Trisul  | protocol_handler 
control PCAP storage on a per-flow basis | packet_storage  
HTTP file extraction | filex_monitor |  s  


these define new objects 

What do I want to do ? Listen to .. |  Script type 
--------------------  | ------------ | ------------
create a new counter group | new_counter_group.lua 
create a new alert group | new_alert_group.lua 
create a new resource group | new_resource_group.lua 


these operate on analytics streams. Backend scripts

What do I want to do ? Listen to .. |  Script type 
--------------------  | ------------ | ------------ 
when a streaming window is opened, closed | engine_monitor.lua 
each new alert . Eg IDS alert, Flow Tracker, etc | alert_monitor.lua 
each new resource in stream. Eg DNS, SSL Cert, HTTP URI, etc| resource_monitor.lua 
each new Full Text Document in stream. Full DNS text in DIG format, Full SSL Cert in OpenSSL format, HTTP headers | fts_monitor.lua 
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
 

