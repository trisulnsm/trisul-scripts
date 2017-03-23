
Links
=====
1. [kiwisyslog.lua](#network-flows--kiwisysloglua) import arbitrary text netflow 'like records' into Trisul
2. [suricate_eve.lua](#alerts) Various methods to import ALERTS from IDS like Suricata 



Input Filters 
=============


Input filters are LUA scripts you write that let you drive Trisul using custom input.

Documentation for _input filters_ can be found at http://trisul.org/docs/lua/inputfilter.html


Samples in this directory demonstrate how to 

1.  Interface to various IDS alert systems (simulataneously) Demonstates the 'step_alert' function
2.  Read Flow and Packet data from custom formats. Demonstrates the 'step' function 


Installing these scripts
========================

Simply pop the .lua files  in /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua 

For more details see http://trisul.org/docs/lua/basics.html#installing_and_uninstalling


Alerts 
======

You can interface to Suricata EVE (which is a great new JSON based format) or to traditional Unified/Unified2 
binary formats using these LUA input filter scripts. We use LuaJIT FFI to talk Unix Sockets. 


### suricata_eve.lua
Suricata writes alerts (and other stuff) to eve.json using the EVE JSON format for IDS alerts.
This script picks that up and pushes _only_ the alerts into Trisul. Also uses a .waldo file to keep track
of where it left off just like traditional logtail systems like Fluentd.


### suricata_eve_unixsocket.lua 
Uses LuaJIT FFI to open a Unix socket and then pull EVE JSON alerts from it.  Demonstrates  the following

1. LuaJIT FFI 
2. How to setup unix socket and create the alert { .. } object 
3. Handle failure by returning false from @onload(..)@ which effectively unloads the script


### snort_unixsocket.lua
By default Trisul opens a single socket to which you can plugin your snort alerts by running it in
'snort -A unsock ..'  - This LUA script lets to do this outside of Trisul.  Demonstrates

1. LuaJIT FFI technique for typecasting,network/byte order 
2. How to unpack a C Struct , extract IP headers etc

### barnyard2_unixsocket.lua
Barnyard2 writes Unix socket in a different format  called Unified2. This LUA script picks up those alerts
and constructs an alert {..} object.   Suitable for use with Security Onion, just turn on  in barnyard2.conf

````
output alert_unixsock
````

Network Flows:  kiwisyslog.lua 
===============

Read a text file containing FLOW information in any arbitrary format, in this case we use Netflow exported 
from ArcSight via KIWISYSLOG.  This script uses each flow record in the text file and drives the Trisul analysis.

To run this script

1. Download the `kiwisyslog.lua` file 
2. Create a new context `trisulctl_probe create context test111` 
3. Start the hub `trisulctl_probe start context test111@hub0`
4. Run the script on a data file as shown below

````
trisul -nodemon /usr/local/etc/trisul/domain0/probe0/context_test111/trisulProbeConfig.xml 
     -mode lua -in kiwisyslog.lua -args NetflowDump.txt 
````
5. Then login to see reports. You can re-run the script after setting the Home Networks by resetting the context `test111`. Reset keeps the 
config but removes the data.

6. Make all changes to configuration on the UI, then reset and re-import

````
trisulctl_probe 
>> stop context test111
>> reset context test111
>> start context test1111@hub0
````

Then reimport the file as shown above.






Network Flows:  lanlflow.lua 
===============

### Shows how to read an arbitrary network flow file and drive Trisul 


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





