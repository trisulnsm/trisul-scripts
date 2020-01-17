# eccerts.rb - Queries all EC-certs and prints curve names 

NSA discovered a critical vulnerability in Windows CryptoAPI in CVE-2020-0601.
Kudelski Security calls it ["Chain of Fools"](https://research.kudelskisecurity.com/2020/01/15/cve-2020-0601-the-chainoffools-attack-explained-with-poc/) 

From a Network Security Monitoring perspective, what I am interested in are the following:

1. How many EC certs are you seeing vs RSA certs ?
2. In those EC certs what are the curve-types you are seeing ?
3. Which domains are using these 
4. Can any improvements be made to the metrics going forward to improve visibility.
5. Can you add live detection ?  

This is the @trisulnsm approach.


## eccerts.rb query certificates

Trisul extracts and stores all X.509 certificates as Full Text Documents, with de-duplication.  
This script here is intented to be run as a batch script 

1. pulls out all SSL Certs FTS documents containing the keyword `id-ecPublicKey`  This gets you all
the EC Certs

2. Uses a simple regex to pull out the curve name from the OID field. Note that the CVE uses explicit attributes 
instead of a pre-packaged curve name.  

```
[vivek@f30 cert-search]$ ruby eccerts.rb tcp://192.168.2.1:12004 1
prime256v1   hubspot.net
prime256v1   usertrustecccertificationauthority-ev.comodoca.com
prime256v1   github.com
prime256v1   *.storage.googleapis.com
prime256v1   *.facebook.com
prime256v1   *.evidon.com
secp384r1   fe3cr.delivery.mp.microsoft.com
...
prime256v1   www.google.com
prime256v1   a248.e.akamai.net
prime256v1   cloudflare.com
prime256v1   *.prod.do.dsp.mp.microsoft.com
prime256v1   ssl817718.cloudflaressl.com
prime256v1   *.storage.googleapis.com
prime256v1   *.googleusercontent.com
prime256v1   *.adnxs.com

TOTALS
prime256v1            51
secp384r1             5
```



