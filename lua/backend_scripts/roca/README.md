Trisul ROCA scanner
===================

Trisul script to scan SSL Certs seen in network traffic for the  ROCA [CVE-2017-15361](http://www.securityfocus.com/bid/101484/info) vulnerability.

There are two LUA files in this directory.

1. `roca.lua`  - A Trisul LUA script to watch certs in live or recorded network traffic 
2. `rocafile.lua` - A standalone test program to check PEM encoded certificate files


roca.lua - scan network traffic
--------------------------------

To install this script simply copy the `roca.lua` file into the Trisul Probe `local-lua` directory. 

````
cp roca.lua /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua
````

Since this script is a [Backend stream](https://www.trisul.org/docs/lua/basics.html#frontend_and_backend_scripts) script this is automatically picked up by a LIVE Trisul system within 1 minute. 


### How roca.lua works

The algorithm in the script is a direct port of the algorithm found in https://github.com/crocs-muni/roca/tree/master/csharp/RocaTest 
What we do here is 

1. Use the [`fts_monitor`](https://www.trisul.org/docs/lua/fts_monitor.html) type that plugs into the SSL Certs stream in Trisul
2. The documents in this stream are SSL Certs in canonical OpenSSL X.509 '-text' format
3. Using regex we pick out all the `Modulus` parts 
4. Then using the magical LuaJIT FFI we pull in the BIGNUM support from libcrypto to implement the algorithms
5. When a cert is detected to be vulnerable we fire an alert. This shows up in the Trisul UI - can be emailed etc etc


rocafile.lua - scan PEM certificate files
------------------------------------------


This is a simple test program that calls the roca.lua functions to check local PEM encoded files. We have included from the crocs-muni repo two test files  cert01.pem (not vulnerable)  and cert05.pem (vulnerable)

To run this file.

1. Install LuaJIT if not already installed
2. Download the roca.lua and rocafile.lua to a directory

Run as shown  below

````
$ luajit rocafile.lua  cert05.pem 
Checking  PEM file cert05.pem
modulus_hex=01a9c5a687db8fb2a30f82dff8dda154c291ef27b04b25e185b8ab20c4c6a5f604859fe59ede54a0af7c0e7288800ad7193bb731a5bf1e1170d7a1c66930d41ea3eb21dedf7b8af5d42a91c34f72045b96efd57cb182301ddcc26967e5508e9ab889986d57e837dfe70f99fc37c498f43c17c3b9b064cf704443d7a033e03a821697aabf30fb29ee7d33b3767965a89058e3b39754bd3a1c007d28a23b0cfa79f9d711ac6e4c4b4f77b0634b1ecd68591af03c7d53b62a5f2d91163d4ef4f8f26831ae461ed85ec5f788c5123ffc12c87420fdcfea1d1b4a52c3521824fb3998348739b62a986d8e76b2289bc2eb8bc06d138147851b83a07183d210559f906321
VULNERABLE...



$ luajit rocafile.lua  cert01.pem 
Checking  PEM file cert01.pem
modulus_hex=009cd30cf05ae52e47b7725d3783b3686330ead735261925e1bdbe35f170922fb7b84b4105aba99e350858ecb12ac468870ba3e375e4e6f3a76271ba7981601fd7919a9ff3d0786771c8690e9591cffee699e9603c48cc7eca4d7712249d471b5aebb9ec1e37001c9cac7ba705eace4aebbd41e53698b9cbfd6d3c9668df232a42900c867467c87fa59ab8526114133f65e98287cbdbfa0e56f68689f3853f9786afb0dc1aef6b0d95167dc42ba065b299043675806bac4af31b9049782fa2964f2a20252904c674c0d031cd8f31389516baa833b843f1b11fc3307fa27931133d2d36f8e3fcf2336ab93931c5afc48d0d1d641633aafa8429b6d40bc0d87dc393
NOT VULNERABLE...


````


Feedback requested
=========

We ran this on our network and traces and could not find any vulnerable certs.  It is probably because we arent using any of the impacted devices.  If anyone would like to deploy on a network you can download Trisul and install this LUA for free to test live traffic. Let us know if you find anything. 


Further reading
===============

For details about deploying this on multiple probes, refer to [Installing and Uninstalling](https://www.trisul.org/docs/lua/basics.html#installing_and_uninstalling)