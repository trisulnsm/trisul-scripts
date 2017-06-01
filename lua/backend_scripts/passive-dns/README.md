# Passive DNS Extractor


Passive DNS is a technique where you listen to DNS messages between clients and servers, then extract IP and Domain Name into a historical database.  Passive DNS databases have wide applications in Network and Security Monitoring. In a streaming analytics system like Trisul, the p-DNS database can be used to enrich or to generate secondary analytics streams in real time. 

> The feature described here is not a full fledged Passive DNS database since we only 
> store IP address and domains. 



## passive-dns-creator.lua

A Trisul LUA Script that builds a live [LevelDB](https://github.com/google/leveldb)  database of IP & Domain info.


We selected LevelDB as the storage because of 
1. concurrency (multiple writers and multiple readers) 
2. embeddability 
3. compact storage 



### How this works

The script makes uses of a LuaJIT ffi helper called tris_leveldb.lua in the helpers subdirectory. Essentially we use LuaJIT FFI magic to cut into the C-API of LevelDB. 


The actual work of extracting DNS is by using a Regex to parse the "DNS FTS Stream". FTS stands for  "Full Text Search" and is one of the stream types in Trisul. The `fts_monitor` LUA script watches the
stream documents and uses a Regex to pick out the mappings and writes it to the DB.

#### See also
[1] FTS Monitor Documentation : https://www.trisul.org/docs/lua/fts_monitor.html



## flowtag-passive-dns.lua
A sample use case we find extremely useful in the real world. The idea is to tag all network flows 
as they are flushed to the databse with the top level domain name (such as google.com, twitter.com, 
etc) so they can be searched that way.

To do that the script

1. uses onmessage(..) to listen for the LevelDB open event and creates a DB object
2. listens to Network Flow Stream using `sg_monitor` LUA type
3. As each flow is flushed tag with the DNS name of the IP

#### See also
[1] Session Monitor Documentation : https://www.trisul.org/docs/lua/sg_monitor.html

## Installing 

Here are the steps to get it installed 

1. Install LevelDB `apt-get install leveldb1` or `yum install leveldb`
3. Copy the helpers/tris_leveldb.lua in a `/local-lua/helpers` subdirectory
4. Copy the other lua files into the `/local-lua` directory
5. Type `trisulctl_probe list lua default@probe0` to check if the scripts loads 
6. Restart trisul-probe 



Links : LUA Scripting API http://trisul.org/docs/lua 
