toja3.rb
=====

Quick script to generate a ja3_hash from this awesome fingerprint DB from https://github.com/LeeBrotherston/tls-fingerprinting/blob/master/fingerprints/fingerprints.json


**NEW : Jan 8 2018 ** Converted and added about 160 prints from John Althouse 

Run
---

````
ruby toja3.rb fingerprints.json > ja3_fingerprints.json
````


Status: currently testing accuracy on a  live Trisul system.  


get_ja3.rb
===========

Ruby Trisul Remote Protocol (TRP) script to automatically correlate unkown ja3 prints from apache webserver logs.


