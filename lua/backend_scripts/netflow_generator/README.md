Netflow v5 Generator
====================

This script turns TrisulNSM into a netflow generator. 


Using
-----


1. Down load the two .lua files.
2. Edit the nfgen.lua and set the `NETFLOW_COLLECTOR_HOST` IP address to the collector IP
3. Place the two .lua files into `/usr/local/lib/trisul-probe/plugins/lua` and restart the Probe.


How it works
------------

1. This script is a _Session Monitor_ script. 



