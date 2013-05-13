Verify certs against the ICSI Certificate Notary
================================================

Trisul 3.0 sample script to check all your SSL Certs in the 
past 24 hours against the ICSI Certificate notary.


The ICSI Certificate Notary http://notary.icsi.berkeley.edu
maintains a list of certificates it has seen based on passive
observation from a number of vantage points. They maintain 
a public DNS service where you can send a query to check if
a certificate you have seen has also been seen and validated 
by them.

"When clients encounter a certificate, they can match it against 
the notary’s version and flag mismatches as possible attacks."


Trisul 3.0 SSL Certificate Resources
------------------------------------

Trisul has always tracked and stored Domain Names and HTTP URLs. From 
R 3.0 it also stores certificate chains. It stores a SHA1 hash of the
DER encoded certificate and also the Subject Name in canonical format.

For example a chain looks like this

````
SHA1:eaac4d85de68a084f5ea7872c2a6b9761e31078e
NAME:/1.3.6.1.4.1.311.60.2.1.3=IT/businessCategory=Private Organization/serialNumber=09339391006/C=IT/postalCode=00187/ST=Italia/L=Roma/street=Via Veneto, 119/O=Banca Nazionale del Lavoro S.p.A./OU=server1/CN=banking.secure.bnl.it
---
SHA1:b18039899831f152614667cf23ffcea2b0e73dab
NAME:/C=US/O=VeriSign, Inc./OU=VeriSign Trust Network/OU=Terms of use at https://www.verisign.com/rpa (c)06/CN=VeriSign Class 3 Extended Validation SSL SGC CA
---
SHA1:32f30882622b87cf8856c63db873df0853b4dd27
NAME:/C=US/O=VeriSign, Inc./OU=VeriSign Trust Network/OU=(c) 2006 VeriSign, Inc. - For authorized use only/CN=VeriSign Class 3 Public Primary Certification Authority - G5
---
SHA1:742c3192e607e424eb4549542be1bbc53e6174e2
NAME:/C=US/O=VeriSign, Inc./OU=Class 3 Public Primary Certification Authority
---

````

1. Each certificate in chain is separated by a '---' string 
2. You can just check the top certificate or the entire chain. 






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






