silk.lua
========

Import SilK (https://tools.netsa.cert.org/silk/docs.html)  netflow  dumps into Trisul for further analysis.


## Why would you want to do this ?

Using this script, you can use Trisul as an analytics platform over a SiLK deployment.  Trisul automatically does all of the counting , aggregating , and indexing you normally want to use. You visually work with hundreds of metrics, flow summaries, toppers, bottom-K, etc. This analysis could be hard to put together using CLI tools alone. 

> #### How this works**  
> We use a named FIFO say `/tmp/silkpipe` to connect the SiLK and Trisul tools. The SiLK tool `rwcat` pumps records into the FIFO . 

## Using this script

Install "TrisulNSM":https://trisul.org/download  and the SiLK tools.  You probably already have this in place. 


**Step 1 : Install the LUA scripts** 

Download the two LUA files in this directory onto the Trisul probe. You can put them in any directory that is world readable, lets say `/tmp`

````
$ ls -l  /tmp
-rw-rw-r-- 1 vivek vivek 8658 May 22 13:43 flowimport.lua
-rw-rw-r-- 1 vivek vivek 4089 May 22 13:43 silk.lua
````


**Step 2 : Create a FIFO** 

This named pipe is the connector between the SiLK world and the TrisulNSM world. 

````
mkfifo /tmp/silkpipe
````


**Step 3:  Run Trisul**

We use the `importlua` tool and a new context to store the data. A context is a separate dataset. 


````bash
trisulctl_probe importlua /tmp/silk.lua /tmp/silkpipe  context=silk111
````

Now, Trisul is waiting for records on the named FIFO `/tmp/silkpipe` You're ready to go


**Step 4:  Run rwcat**

rwcat is used to send silk files to the FIFO. You can set up a live system or play out previously captured `YAF` files. The following example shows how you can dump a YAF file to the FIFO.  Note that we need to uncompress it as shown.


````bash
$ rwcat --ipv4-output --compression=none /tmp/a12.yaf -o /tmp/silkpipe

````

Now you can logon to the `silk111` context and view reports.

---- 


## A note about SiLK and ifIndex  


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

1. SiLK documentation : https://tools.netsa.cert.org/silk/docs.html
2. Blog post : [How to send flow record to trisul](https://www.unleashnetworks.com/blog/?p=688)
