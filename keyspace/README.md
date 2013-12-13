Active keys in a range
======================

The KEYSPACE_REQUEST command is used to retrieve the active keys in a range.

This request can be used to retrieve all IPs seen in the 10.x.x.x private IP range.

This directory has two scripts

1. active_keys.rb - Print all active keys in Trisul Key Format 
2. active_keys2.rb - Print all readable resolved keys, uses an additional message called KeyLookup 


### TRP Messages used

The above script uses the following TRP Messages

1. [KeySpace](http://trisul.org/docs/ref/trpprotomessages.html#keyspace)  - to retrieve keys in a range 



### Sample run


The following run displays the all Ports  seen in the range p-0000 to p-1000. In Trisul key format
this equate port 0 to port 4096 

Note that "Apps" counter group has the GUID {C51..} and the keys are in Trisul Key Format.

The active_keys2.rb script extends the base script to convert human readable keys into Trisul Key Format. We've separated the two scripts to highlight use of the KeySpace message.



```
[vivek@longdog trp]$ ruby active_keys.rb  192.168.1.22  12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0000 p-1000
Enter PEM pass phrase:
Found 15 matches
Hit Key  p-000D 
Hit Key  p-0016 
Hit Key  p-0035 
Hit Key  p-0043 
Hit Key  p-0050 
Hit Key  p-007B 
Hit Key  p-0089 
Hit Key  p-008A 
Hit Key  p-01BB 
Hit Key  p-034B 
Hit Key  p-03E1 
Hit Key  p-076C 
Hit Key  p-078F 
Hit Key  p-0BB8 
Hit Key  p-0C3B 


```
This is how active_keys2.rb works for the same input 

````
[vivek@longdog trp]$ ruby active_keys2.rb  192.168.1.22  12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0000 p-1000
Enter PEM pass phrase:
Found 15 matches
Hit Key  p-000D  daytime 
Hit Key  p-0016  ssh 
Hit Key  p-0035  domain 
Hit Key  p-0043  bootps 
Hit Key  p-0050  http 
Hit Key  p-007B  ntp 
Hit Key  p-0089  netbios-ns 
Hit Key  p-008A  netbios-dgm 
Hit Key  p-01BB  https 
Hit Key  p-03E1  imaps 
Hit Key  p-076C  ssdp 
Hit Key  p-078F  macromedia-fcs 
Hit Key  p-0BB8  remoteware-cl 
Hit Key  p-0C3B  netbookmark 


````


