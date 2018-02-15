Netflow v5 Generator
====================

This script turns TrisulNSM into a netflow generator. 
The purpose of this script is to demonstrate the flexibility of the Trisul LUA API while developing a functional Netflow generator.


Using
-----


1. Down load the two .lua files.
2. Edit the nfgen.lua and set the `NETFLOW_COLLECTOR_HOST` IP address to the collector IP
3. Place the two .lua files into `/usr/local/lib/trisul-probe/plugins/lua` and restart the Probe.


How it works
------------

1. This script is a [Session Monitor](https://www.trisul.org/docs/lua/sg_monitor.html)  This is a Trisul "Backend" or "slow path" script that is called when session (flow) stream events occur.  
2. We plug into the session snapshotting process that occurs every minute by default.  
3. As each flow is flushed to the Trisul Hub node, we also send out a Netflow v5 packet
4. The good stuff happens using our favorite scripting framework. LuaJIT-FFI ; the FFI interface is like magic you can just call 'C' routines without any compilation step.  
5. We take care to pack as many netflow records into a UDP datagram as possible. 

some points of interest
------------------------

1. NetflowV5 is Uni-Directional but Trisul flows are Bi-Directional. So we generate 2 netflow records per flow. 
2. You can extend this to Netflowv9, which would make it easier to deal with the Bi-Directional flows. 




