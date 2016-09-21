Custom input filter for Trisul to process the sample flow DB
======

lanlflow.lua 
------------

LANL has published about 58 days of network flow data for cyber security purposes at
http://csr.lanl.gov/data/cyber1/

The flows.txt.gz file is a 1.1G dump that contains netflow like data in the format

time,duration,source computer,source port,destination computer,destination port,protocol,packet count,byte count

The IP addresses and ports are anonymized using plain strings, for example this is what a line from the logfile looks like 

````
1,9,C3090,N10471,C3420,N46,6,3,144
1,9,C3538,N2600,C3371,N46,6,3,144
2,0,C4316,N10199,C5030,443,6,2,92
````


How lanlflow.lua works
----------------------
The lanlflow.lua script is an *inputfilter* LUA script that can drive the Trisul Network Analytics pipeline. 
What we do in this script is convert the strings into IP addresses. We simply hash them to a 32 bit number and 16 bit number and use that. 

The script then uses the _Engine_ methods to update various metrics.





