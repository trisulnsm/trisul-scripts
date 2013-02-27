APT1 detector MD5 and FQDN
==============================

Sample script to scan all your traffic for MD5 content matches and FQDNs easily.


The big news this month in the field of network security monitoring is
the APT1 indicators released by Mandiant. It is clear that tools today 
must have the ability to search for things such as content matches etc.


This directory  includes two scripts search_md5.rb , and search_fqdn.rb 
We already have another sample that extracts TLS certs. see the cert-extract directory.

search_md5.rb (scan all HTTP content for MD5 match)
-------------
Takes as input a file containing MD5 hashes (one hash per line), then
connects to a running Trisul instance. All HTTP traffic is opened up
and their content (files,javacript,images,everything) is compared.

On a low end AMD Althon dev machine we acheived a 250MBytes/sec scan rate.

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

search_fqdn.rb  (Search all names for DNS match)
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

# search_md5_adv
For each md5 match pulls out a PCAP of the flow and saves it with as "md5:xxxx.pcap"

```
..

1,361 2008-02-12 20:42:40 +0530 a1343.g.akamai.net  192.168.1.2 caps-lm          123388     16312
1,388 2008-02-12 20:45:42 +0530 a868.g.akamai.net   192.168.1.2 appman-server     27573      1958

Wrote pcap MD5:627c405e3d4969e57f48dd09289aa29d.pcap
Wrote pcap MD5:18edd24a1cd4496578c50fe2efd1a9a8.pcap
Wrote pcap MD5:d5753af0d384857ca34bf8b54c5eb417.pcap
Wrote pcap MD5:ed9472ba7d8ca2920e8e93aab38e5aa4.pcap
Wrote pcap MD5:0d539981335c18acacd9a0c2c7ca8f0d.pcap
```

# search_fqdn_adv
Prints full details of each match.

Run the "_adv.rb" version of the scripts with the same command line.






