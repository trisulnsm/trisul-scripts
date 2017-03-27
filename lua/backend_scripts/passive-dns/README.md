# Passive DNS Extractor

Links : LUA Scripting API http://trisul.org/docs/lua 

Passive DNS is a technique where you listen to DNS messages between clients and servers, 
then extract IP and Domain Name into a historical database.

Passive DNS databases have wide applications in Network and Security Monitoring. Particularly 
in the context of a streaming analytics system like Trisul, the p-DNS database can be used to
'mark' IP addresses in flows or generate secondary analytics streams. We selected LevelDB as the
backend storage because of 1) thread safety 2) embeddability and 3) compaction. 


In this page you will find two scripts :

1. passive-dns-creator.lua  --  listens to Trisul DNS FTS (Full Text) streams and extracts Answer Records
                                into a LevelDB database. 
2. flowtag-passive-dns.lua  --  a sample usage of passive dns. Tags all flows with the top level DNS name
                                so that you can search for flows like ````tag=twitter.com```` 

## passive-dns-creator.lua

The script makes uses of a LuaJIT ffi helper called tris_leveldb.lua in the helpers subdirectory.  This
helper uses the C API of LevelDB.  You can take a look at that script. You may be wondering why open(..) returns 
a string representing the address and then uses that address  as upvalues to read(..) and write(..) methods. The
reason is the way Trisul hosts your LUA scripts. It is multi threaded and multiple instances of your LUA script
can be loaded at the same time and the only way you share state is via post_message(..). In other words, there is 
no "global" state.  The example creates a leveldb object, then passes the opaque pointer as a C-String, then
any LUA script can listen to this message and use the leveldb object. 

The actual work of extracting DNS is by using a Regex to parse the FTS Stream. FTS is "Full Text Search". By
using the fts_monitor LUA script attached to the DNS FTS type , you can pick out these DNS Answer Records. 


## flowtag-passive-dns.lua

This is an example use case we find extremely useful in the real world. The idea is to tag all network flows as they 
are flushed to the databse with the top level domain name (such as google.com, twitter.com, etc) so they can be searched 
that way.

To do that the script

1. uses onmessage(..) to listen to passive DNS DB pointer becoming available then creating the LUA closures 
2. listens to Network Flow Stream using sg_monitor LUA type
3. As each flow is flushed tag with the DNS name


## Installing 

You need to first install leveldb ; use the following steps

* We will be installing the LUA Scripts in a probe-local context at `/usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua`` See http://trisul.org/docs/lua/basics.html#installing_and_uninstalling 


1. Download and compile LevelDB from https://github.com/google/leveldb/releases
2. Copy the libleveldb.so library (found in out-shared) into the `../local-lua` directory
3. Copy the helpers/tris_leveldb.lua in a `/local-lua/helpers` subdirectory
4. Copy the other lua files into the `/local-lua` directory
5. Type `trisulctl_probe list lua default@probe0` to check if the scripts loads 
6. Restart trisul-probe 



