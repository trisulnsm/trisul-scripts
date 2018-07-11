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


$ du -sh critical-stack.trisul.0/
30M     critical-stack.trisul.0/

````

### Place the compiled database in the data directory where it can be found

Copy the compiled DB 

```
cp -r  critical-stack.trisul.0 /usr/local/share/trisul-probe/plugins/critical-stack.trisul.0
cp -r  critical-stack.trisul.0 /usr/local/share/trisul-probe/plugins/critical-stack.trisul.1

```

#### Installing the compiled database - issues 

1. We are copying the database twice because we have two backend engines running in Trisul, so they can each lookup concurrently.  
2. Ensure the databases are readable by user `trisul` : Do `chown -R trisul.trisul critical-stack.trisul*` if required


## Simple lookup that generates an alert when there is a IOC hit 

Put the critical-stack-checker.lua script into the Trisul LUA directory for your probe and context. 

Copy the critical-stack-checked.lua and tris-leveldb.lua files into /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua/

Restart the probes 




