Sweeping past traffic against OpenIOC Intel 
================================================

Trisul 3.0 sample script to demonstrate how you 
can consume an OpenIOC format feed and sweep past
traffic for matches.



The ruby script checknotary.rb
------------------------------------

Note : You also need the dnsruby gem. ( sudo gem install dnsruby  )

The script is quite straightforward.

1. Connects to a Trisul Probe at a given IP Address
2. Sends a TRP Resource Group Request to retreive all SSL Resources (new in 3.0)
3. FOr each resource, which is actually a chain of certificates, extract each cert
4. For each cert, use the SHA1 to send a DNS txt query to {sha1}.notary.icsi.berkeley.edu
5. If you get a NXDOMAIN response - log the offending cert & print subject name
6. If you get a TXT response, check for validated=1 and print subject name if not 
7. We use a caching scheme so we dont check the same cert twice 


Sample output 
-------------

Before running make sure you have the TRP client cert and private key in your running directory.
See the top level README for more.

````
$ ruby checknotary.rb 192.168.1.22 12001
Enter PEM pass phrase:
Found 720 matches
5604e5921ea362403c500c4865794905f6fde310.notary.icsi.berkeley.edu....[OK VALID]
59676e6bdd9f4d9ddae6a15d9dbcdf24357cf776.notary.icsi.berkeley.edu....[OK VALID]
f56bf24463b0bd6136c5e872346b320428ff4d7c.notary.icsi.berkeley.edu....[OK VALID]
d559a586669b08f46a30a133f8a9ed3d038e2ea8.notary.icsi.berkeley.edu....[OK VALID]
97e82560e3e8b2db741e38f1f798a89dd676cec0.notary.icsi.berkeley.edu....[OK VALID]
59e4d36def09e650989c6a014e544695b2db6d30.notary.icsi.berkeley.edu....[OK VALID]
2796bae63f1801e277261ba0d77770028f20eee4.notary.icsi.berkeley.edu....[OK]
    ^-- not validated NAME:/C=US/O=The Go Daddy Group, Inc./OU=Go Daddy Class 2 Certification Authority

1a2f57d655b790fa723d92f74aafa17fbdfbe986.notary.icsi.berkeley.edu....[FAIL - NXDOMAIN]
    ^-- failed NAME:/C=IN/ST=KA/L=<redact>/O=<redact>/OU=<redact>/CN=<redact>/emailAddress=support@xxxxnetworks.com

658f37cc79f4c67451ef58c15f789390f26288fb.notary.icsi.berkeley.edu....[OK VALID]


````

Some of the validation failures maybe due to the fact that we are checking root CAs also. You can modify the code as you please to only check the servers certificate.

