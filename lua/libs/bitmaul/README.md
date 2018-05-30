BITMAUL - The Mauler of packetz 
======

![BITMAUL ICON ](https://github.com/trisulnsm/trisul-scripts/raw/master/lua/bitmaul/maulaxe.png)

BITMAUL is a LUA helper library to help you write protocol dissectors. 

There are two libs you can use independently. 

1. **sweepbuf** : Extract protocol fields from a chunk of bytes
2. **pdurecord**  : Constructs TCP records / PDUs from bytestream 


#### Usage

Just put the files `sweepbuf.lua` and `pdurecord.lua` in the same directory as your LUA scripts. 


Bitmaul Docs
=============

Read the documentation for the two pieces of Bitmaul.  SweepBuf is the dissector library that lets you extract info from byte buffers.  PDURecord makes it really easy to pick out the full message byte buffers from a bytestream.  

 * for a TCP based analyzer, you typically need to use both PDURecord and SweepBuf
 * for a UDP/Ethernet analyzer, you might only need SweepBuf 
 

SweepBuf documentation
----------------------

Sweepbuf works on a LUA string which represents a network payload byte array.  The library maintains an internal "pointer" so you can use methods like `next_XYZ(..)` to extract fields.  Common network idioms like endian-ness, searching for terminators, looping over attribute values, are all supported.

Read [SweepBuf Documentation](SWEEPBUF.md)



PDURecord documentation
-----------------------

A common first step in any stream based packet dissection is breaking up a bytestream into Protocol Data Units (PDU/records/messages). PDURecord is a tiny library that makes it really easy to do this. 

Read [PDURecord Documentation](PDURecord.md)



