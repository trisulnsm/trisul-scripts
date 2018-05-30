# SweepBuf documentation

Sweepbuf works on a LUA string which represents a network payload byte array.  The library maintains an internal "pointer" so you can use methods like `next_XYZ(..)` to elegantly extract fields. Common network idioms like endian-ness, searching for terminators, looping over attribute values, are all supported. 

> #### What does SweepBuf mean ? 
A typical network protocol dissector calls a sequence of next_XXX(). This return the field at that position and then advanced the internal pointer. This reflects typical network protocol design which enables a single pass sweep. Hence the name _SweepBuf_ for "Sweep a Buffer". 

Doc links :  [Construction](#construction) | [Extracting number fields](#extracting-numbers) | [Extracting arrays](#extracting-arrays-of-numbers) | [String fields](#extracting-strings) | [Record fields](#working-with-records) | [Utility functions](#utility-methods) | [Full examples](#examples) 

## Construction

If you have a byte buffer stored in `bytestring` construct a SweepBuf over it like so

````lua
local SWP=require 'sweepbuf.lua'

sw=SWP.new( bytestring)

checksum=sw:next_u16()  -- use sw 

````

## Extracting numbers 

For example if a part of your  protocol is 

````cpp
..
byte        message_type;       /* 1 byte  */
uint16_t    message_length;     /* 2 bytes */   
uint32_t    timestamp;          /* 4 bytes */
...

```` 

You would use something like this. 

````lua

local SWP=require 'sweepbuf.lua'
sw=SWP.new( bytestring)


mtype = sw:next_u8()
mlen  = sw:next_u16()
ts    = sw:next_u32()


````

Under the covers SweepBuf automatically converts from network byte to host byte order `ntohs/ntohl` 


### Methods Reference 

You would most likely be working with the following `next_` functions. These return the field at the current position and then advanced the internal pointer. 

* next_u8 - unsigned byte
* next_u16 - unsigned 16 bit number
* next_u24 - unsigned 24
* next_u32 - unsigned 32 

Then the Little Endian versions. Rarely network protocols use this. 

* next_u8_le - unsigned 8 bits
* next_u16_le - unsigned 16 bits when buffer contents in little endian 
* next_u24_le
* next_u32_le

These functions return the value but do not advance the internal pointer.

````lua 
checksum = payload:u32()
payload:inc(4)

is the same as
checksum = payload:next_32() 
````

* u8 - unsigned 8 bits
* u16 - unsigned 16 bits
* u24 - unsigned 24 bits
* u32 - unsigned 32 bits


## Extracting arrays of numbers 

These enable a common idiom found in network protocols, an array of fields.  You can consider the following specification of the SSL/TLS protocol.

````c
 {
 	uint_16  cipher_suite_bytes;
 	uint_16  cipher_suites[]
 }

````


You can get the cipher suites into a LUA array 

````lua 
local suite_len = payload:next_u16()
local Ciphers = payload:next_u16_arr( suite_len/2)

-- or on a single line 

local Ciphers = payload:next_u16_arr( payload:next_u16()/2)

````


### Methods Reference 

You would most likely be working with the following `next_` functions. These return the field at the current position and then advanced the internal pointer. 

* next_u8_arr(nitems) = Array of nitems of u8
* next_u16_arr(nitems) = Array of nitems of u16
* next_u32_arr(nitems) = Array of nitems of u32


## Extracting Strings

In network protocols , strings are generally represented by one of two mechanisms.  

* Length prefix or
* delimited 

Here is an example of length prefixed string.

````c
	uint16_t  username_len
	char      username[username_len]
````

This is a length prefixed string and the length field is a u
````lua
	local slen = payload:next_u16()
	local username = payload:next_str_to_len(slen)

````

Or in a single line 
````lua
	local username = payload:next_str_to_len( payload:next_u16())
````


Here is an example of delimited string. By `\r\n` a common delimiter

````lua
	local username = payload:next_str_to_pattern( '\r\n')
````


### Methods reference

These two methods should cover 99% of common network protocol idioms. 

* next_str_to_pattern (patt) = extract string till you see the Regex pattern
* next_str_to_len(string_len) = extract string of length




## Working with records 

Records are another common pattern in network protocols. There is a record of some sort that is repeated until a particular end position.

Say you have something like

````c
	
	Extensions = struct {
		uint16_t  ext_type;
		uint16_t  ext_len;
	}

	uint16_t  extensions_length;
	Extensions extensions;
````


You can use the fence methods to set the end position and loop until you hit the end.

````lua
    payload:push_fence(payload:next_u16())

    local snihostname  = nil

    while payload:has_more() do
	          local ext_type = payload:next_u16()
	          local ext_len =  payload:next_u16()
	          if ext_type == 10 then
	end
	payload:pop_fence() 

````


### Methods Reference 


* push_fence(bytes_ahead) = Set a fence at bytes_ahead from the current position.
* has_more() = Has the fence been hit 
* pop_fence() = remove the fence, back to one level up.

Sweepbuf allows you to nest fences to reflect nested record structures.


## Utility methods

* `hexdump()` prints a hexdump of the byte buffer in a canonical format.
* `split(str,delim)` Utility method to split a string
* `to_string()` prints details about the SweepBuf object itself, like size of string, position of the pointers, etc.
* `reset()` reset the seek pointer and remove all fences 
* `inc(nbytes)`  move the internal pointer by n bytes. 
* `skip(nbytes)`  skip n bytes. 
* `bytes_left` how many bytes left to process. End - current internal pointer position


## Examples

See for sweepbuf usage in real application 

 - Trisul APP [TLS Server Name Indication](https://github.com/trisulnsm/apps/tree/master/analyzers/sni-tls) for a full working example.
 - Trisul APP [JA3 Hash TLS Fingerprint](https://github.com/trisulnsm/apps/tree/master/analyzers/tls-print) 
