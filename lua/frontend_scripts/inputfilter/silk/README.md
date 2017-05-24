silk.lua
========

Import SilK (https://tools.netsa.cert.org/silk/docs.html)  data dumps into Trisul for further analysis.

SiLK is a suite of tools that work with large scale Netflow/IPFIX monitoring.  The flows are stored in "packed" files by the packing tools. Then there is another set of analysis tools to read data off the packed files and perform some analysis.

This script allows you to feed the packed files as input to the Trisul Streaming Analytics pipelines. This gives you spectacular visibility that would be quite hard to put together with the tools alone. 



How this works ?
-----------------

The tool `rwcat` is used to read SiLK dump files and write them to a named pipe, this lua script (silk.lua) readsfrom the named pipe, converts each binary record, and pushes into Trisul pipeline.


Running the script
-----------------

This script depends on the helper module `flowimport.lua` available in the parent directory. 

1. Download silk.lua and flowimport.lua in a directory say @/tmp/@
2. `mkfifo /tmp/silkpipe` to create the named pipe
3. `rwcat --ipv4-output --compression=none file1.17  -o /tmp/silkpipe` to write records

Then you need to start Trisul, the best way is to create a new context and use that.
1. Run `trisulctl_probe`
2. `create context silk111'
3. `start context silk111 mode=initdb`
4. At this time you can login and set home networks and other settings
5. Start trisul `trisulctl_probe importlua /tmp/silk.lua  /tmp/silkpipe`

To view the progress you can check the logs
1. trisulctl_probe 
2. 'log silk111@probe0 log=ns tail' to view

Once the import is done, you can log in and voilA! 


A note about SiLK and ifIndex  
------------------
By default SiLK suite do not seem to store the SNMP input and output inteface numbers that are present in Netflow.  Trisul uses the interface information to enable device based drilldowns.    


Make sure you enable `--pack-interfaces` for maximum benefit. 

*Example* : If you are running `rwflowpack` to process Netflow/IPFIX, you need to use the flags as shown below. 

````
root@Inspiron-3442:~# /usr/local/sbin/rwflowpack '--pack-interfaces' \
 '--sensor-configuration=/data/sensor.conf' \
  '--compression-method=best' '--site-config-file=/data/silk.conf' \
  '--archive-directory=/usr/local/var/lib/rwflowpack/archive' \
  '--output-mode=local-storage' \
  '--root-directory=/data' \
  '--pidfile=/usr/local/var/lib/rwflowpack/log/rwflowpack.pid' \
  '--log-level=debug' \
  '--log-destination=syslog' '--no-daemon'
````


Ref
----

SiLK documentation : https://tools.netsa.cert.org/silk/docs.html