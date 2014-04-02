Buffer
======

LUA Scripts that demonstrate how you can deal with raw packet bytes.


Trisul does not copy over the raw packets to from the C to the LUA side, 
instead it provides an abstraction called "Buffer" that allows you to 
retrieve the information you seek.



tcphdr.lua
----------

Prints the TCP header to stdout. This demonstrates how you can extract numbers in 
network to host order and also how to extract bits such as the TCP flags. 


