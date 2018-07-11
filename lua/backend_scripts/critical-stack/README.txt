How to integrate Critical-Stack Threat intel feed with Trisul
==========


This is a small demo that explains the following recommended technique in TrisulNSM to 
scan your network traffic for threat indicators or for other types of metering. 


1. first install the "IOC-Harvestor" Trisul APP
2. then compile the intel data into a LevelDB database using our tris_leveldb library
3. a simple lookup script that watche the IOC-Harvestor stream and validates each item against the LevelDB

This technique can support really large threat databases due to the superior lookup performance of LevelDB



##  Installing the IOC-Harvestor App

Login as Admin and install the IOC-Harvestor App. This plugins into various streams in TrisulNSM and 
creates a new separate stream called "IOC-Harvestor" 


## Compile the critical stack feed

Dont be shy, just enable all the feeds using the `critical-stack-intel` client. That will create a
single tab separated text file containing all the indicators called `master-public.bro.dat`. This is going to 
be our input file.



Run the following command to compile into a LevelDB database called `critical-stack.trisul.0` 

````
$ luajit compile-cs.lua  master-public.bro.dat  critical-stack.trisul.0 

Processing master-public.bro.dat
Compiled 615231 indicators into output database critical-stack.trisul.0

````

## Simple lookup that generates an alert when there is a IOC hit 

Put the cs-trisul.lua script into the Trisul LUA directory for your probe and context. 

Copy the cs-trisul.lua and tris-leveldb.lua files into /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua/


Restart the probes 


