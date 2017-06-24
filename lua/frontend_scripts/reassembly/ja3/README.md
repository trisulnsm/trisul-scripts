IOC based on Client Hello fingerprinting 
======================

An experiment at collecting client hello fingerprints for malware detection
application.


This method is an implementation of https://github.com/salesforce/ja3  


What ja3.lua does 
--------------

1. A LUA  `reassembly_handler` that listens to reconstructed TLS records as they
stream by. Ignores everything except Client Hello Handshake records. 

2. Dissects the Client Hello record and pulls out the required fields for JA3.
!Hey - its not as hard as it sounds - check out the helper methods in the lua
file.

3. Adds a new Resource Group called "JA3 Hash" and adds hashes to that group.
The flow ID is also added, so Trisul can pivot off that to PCAPs etc.


