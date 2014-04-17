APT1 detector MD5 and FQDN
==============================

Sample scripts to scan all your traffic for MD5 content matches, IP Ranges, Text, and DNS names.

This directory  includes four scripts 

* search_md5.rb - Reassemble all files and check their MD5s against a list 
* search_fqdn.rb - Check list of DNS domains
* search_text.rb,  - Reassemble all files and search for arbitrary text/binary patterns
* search_keyspace.rb - Check for activity from multiple IP blocks 

You can use these four sample scripts as a building block to cover a majority of 
network based indicators of compromise.

Also see the cert-extract directory for additional scripts to process SSL/TLS certificates.

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

search_text.rb  (Search for a string match)
-------------------------------------------

Input is a string (the longer the better). Reassembles all TCP and
normalizes all HTTP while searching. Did I say longer the better ?

The output : Trisul flow ids


Once you have the flow-ids you can pull out packets or related flows/alerts etc.

```
ruby ../trisul-scripts/apt1-detect/search_text.rb  127.0.0.1  12001 "kontera"
Enter PEM pass phrase:
Found 7 matches
Flow 1:354  xt/javascript" src="http://kona.kontera.com/javascript/lib/KonaLibInlin 
Flow 1:361  .NET CLR 2.0.50727)\x0D\x0AHost: kona.kontera.com\x0D\x0AConnection: Keep-Alive\x0D\x0ACo 
Flow 1:360  .NET CLR 2.0.50727)\x0D\x0AHost: kona.kontera.com\x0D\x0AConnection: Keep-Alive\x0D\x0ACo 
...

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




search_keyspace.rb  (Search for a IP ranges)
-------------------------------------------

See the ip-ranges.txt file for a sample input file. 
You an search ranges or a single IP.

````
$ ruby search_keyspace.rb 192.168.1.8 12001 ip-ranges.txt 
Enter PEM pass phrase:

Found 53 matches
Hit Key  C0.A8.01.01 
Hit Key  C0.A8.01.08 
Hit Key  C0.A8.01.16 
Hit Key  C0.A8.01.21 
Hit Key  CA.4F.D2.79 

````


