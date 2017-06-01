skip_youtube.lua
================

In the Network Security Monitoring (NSM) paradigm the ability to access raw packets is a central feature.

However not all organizations have the budget to adopt a 'store every bit' position due to
the prohibitive cost. Fortunately you can adopt a smart storage strategy that can get you close to 
99% of the benefits of the 'store every bit' strategy at maybe 20-30% of the cost. 

This script uses the *packet_storage*  LUA script type in Trisul to implement the following policy.

1. All Netflix, Youtube, and Twitter packets arent stored.
2. In many environments, this could be a 50-60% savings right away
3. You can extend this framework to cull trusted high volume flows to suit your enterprise

How this works
---------------

1. The Passive DNS extractor [2] is a pre-requisite. It builds a LevelDB database containing real time IP->Domain mapping 
2. skip_youtube.lua uses the *filter* method to check each new flow _(not each packet)_ against the allowed list and determines the storage policy as 'discard' or 'allow'


References
----------

1. LUA *packet_storage* API  reference : https://www.trisul.org/docs/lua/packet_storage.html
2. Passive DNS extractor : https://github.com/trisulnsm/apps/blob/master/analyzers/passive-dns/README.md




