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

2. Then for each certificate in each chain,  compute the public key algorithms used. 

3. Mark any EC public key which is not a named  curve with the string "unnamed_explicit_curve" 

4. Print totals 

## Interpreting the output 

The script prints two parts

- a dump of cert chain CN= and the public key algorithm in the chain
- totals 

### EC certs Dump 

In the following example 
````
prime256v1/prime256v1/secp384r1     ssl416124.cloudflaressl.com/COMODO ECC Domain Validation Secure Server CA 2/COMODO ECC Certification Authority
````

The cert chain is 3 deep with the _cloudflaressl_ at top signed with `prime256v1`, the next one is a `prime256v1` EC from _COMODO DV_, the root is a _COMODO ECC CA_ 

### Totals 

Here a total count of the algorithm chain is shown. Here you can see 
```
secp384r1/unnamed_explicit_curve          2
```
This is actually due to one of us from our team visiting the testing site !! 


```
TOTALS
PUBLIC KEY ALGO CHAIN                   COUNT
prime256v1/secp384r1                      10
rsaEncryption/rsaEncryption/secp384r1     1
prime256v1/prime256v1/secp384r1           5
prime256v1/rsaEncryption                  19
prime256v1/rsaEncryption/rsaEncryption    1

```


```
[vivek@fedo30 cert-search]$ ruby eccerts.rb tcp://192.168.2.1:12004 0 
prime256v1/secp384r1               odc-prod-01.oracle.com/DigiCert ECC Secure Server CA 
rsaEncryption/rsaEncryption/secp384r1     bko.dynadmic.com/GlobalSign RSA OV SSL CA 2018/GlobalSign
prime256v1/secp384r1               *.evidon.com/DigiCert ECC Secure Server CA            
prime256v1/prime256v1/secp384r1     ssl416124.cloudflaressl.com/COMODO ECC Domain Validation Secure Server CA 2/COMODO ECC Certification Authority
prime256v1/secp384r1               *.adnxs.com/DigiCert ECC Secure Server CA
prime256v1/rsaEncryption           *.google.com/GTS CA 1O1                                                                                        
prime256v1/rsaEncryption           *.googleapis.com/GTS CA 1O1                    
prime256v1/rsaEncryption           AnyNet Relay/AnyNet Root CA/O=philandro Software GmbH/C=DE
prime256v1/rsaEncryption           www.google.com/GTS CA 1O1                  
prime256v1/rsaEncryption           mail.google.com/GTS CA 1O1                                                                          
prime256v1/rsaEncryption           *.storage.googleapis.com/GTS CA 1O1              
prime256v1/rsaEncryption           *.facebook.com/DigiCert SHA2 High Assurance Server CA
prime256v1/rsaEncryption           *.g.doubleclick.net/GTS CA 1O1
prime256v1/rsaEncryption           *.wikipedia.org/DigiCert SHA2 High Assurance Server CA
prime256v1/rsaEncryption           *.googleusercontent.com/GTS CA 1O1
secp384r1/unnamed_explicit_curve     SANS ISC DShield Test/INFIGO
prime256v1/prime256v1/secp384r1     ssl470552.cloudflaressl.com/COMODO ECC Domain Validation Secure Server CA 2/COMODO ECC Certification Authority

..

prime256v1/secp384r1               *.livechatinc.com/DigiCert ECC Secure Server CA


TOTALS
PUBLIC KEY ALGO CHAIN                   COUNT
prime256v1/secp384r1                      10
rsaEncryption/rsaEncryption/secp384r1     1
prime256v1/prime256v1/secp384r1           5
prime256v1/rsaEncryption                  19
secp384r1/unnamed_explicit_curve          2
prime256v1/prime256v1                     3
prime256v1/rsaEncryption/rsaEncryption    1

```



