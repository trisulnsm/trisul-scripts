ja3fingerprint.json
====================

A database of JA3 Fingerprints in JSON format. 

The original sources of these prints can be found as comments.  If you have stumble across any reliable  JA3 Print not seen in the list, please submit a pull request. 


For more about JA3 :  https://github.com/salesforce/ja3  


Changes
========

````
Mar 1 2018     55 Malware Prints thanks to JunPritsker from malware-traffic-analysis PCAPS  
Jan 8 2018     Converted and added about 160 prints from John Althouse 

````



Other files in this directory
------------------------------


There are some other utility scripts in this directory to convert from various different formats into the JSON format.


toja3.rb
---------

Quick script to generate a ja3_hash from this awesome fingerprint DB from https://github.com/LeeBrotherston/tls-fingerprinting/blob/master/fingerprints/fingerprints.json

To run 

````
ruby toja3.rb fingerprints.json > ja3_fingerprints.json
````


to_fingerprints.rb
-------------------

Reverse  of toja3.rb. 


get_ja3.rb
------------

Ruby Trisul Remote Protocol (TRP) script to automatically correlate unkown ja3 prints from apache webserver logs.



csv_toja3.rb
--------------

Convert CSV to JSON. 