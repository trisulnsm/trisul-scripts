APT1 detector MD5 and FQDN
==============================


Scan all your traffic for MD5 content matches and FQDNs easily.


This directory  includes two scripts.

# search_md5  :  Scan all HTTP content for MD5 matches 
# search_fqdn :  Search all  *name* resources for matches 


search_md5.rb
-------------
Takes as input a file containing MD5 hashes (one hash per line), then
connects to a running Trisul instance. All HTTP traffic is opened up
and their content (files,javacript,images,everything) is compared.

The output : Trisul flow id: Containing the flow id of the match.




```
[vivek@tris7east trp]$ ruby search_md5.rb 192.168.1.1 12001 md5s.txt 
Enter PEM pass phrase:
Found 5 matches
Flow 1:73 MD5:627c405e3d4969e57f48dd09289aa29d 
Flow 1:108 MD5:18edd24a1cd4496578c50fe2efd1a9a8 
Flow 1:223 MD5:d5753af0d384857ca34bf8b54c5eb417 
Flow 1:361 MD5:ed9472ba7d8ca2920e8e93aab38e5aa4 

```

search_dns.rb 
-------------
Input is a file containing FQDNs (one per line). The script connects to
Trisul and prints matching resources found.

The output : Trisul resource ids.

```
[vivek@tris7east trp]$ ruby search_fqdn.rb 127.0.0.1 12001 dnss.txt 
Enter PEM pass phrase:
Found 2 matches
Resource 1:309 
Resource 1:315 

```


Advanced versions _adv.rb
=========================

We didnt want to clutter the basic versions of md5 and dns matching. 

The real fun is in the search_md5_adv.rb  and search_fqdn_adv.rb scripts.

# search_md5_adv  : For each md5 match pulls out a PCAP of the flow and saves it with as "md5:xxxx.pcap"

# search_fqdn_adv : Prints full details of each match.


Run the "_adv.rb" version of the scripts with the same command line.






