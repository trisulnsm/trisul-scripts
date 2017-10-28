FireHOL.lua  - Trisul Plugin to alert on FireHOL matches
=================================

This LUA script tracks all newly seen IPs against the excellent FireHOL Cyber Crime Feeds at http://iplists.firehol.org/


Using
-----

This is also available as a Trisul App for free download, but if you want to use this script separately

Download the FireHOL IP Ranges file and put it in this directory

````
cd /usr/local/share/trisul-probe
curl -O https://iplists.firehol.org/files/firehol_level1.netset
````

Place the 2 lua scripts in the local-lua directory

````

cp firehol.lua /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua
cp iprangemap.lua /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua

````

The script will be automatically picked up by a LIVE instance of Trisul within 1 minute.


Output Alert
------------

When a match is seen you will immediately get an alert. 
Log on to Trisul , then go to Alerts > Show All > User Alerts > View Real Time 

