# PDURecord documentation

A byte stream is nothing but raw bytes where you no idea where the message boundaries are. All protocols that run on top of TCP have some kind of message boundary markers. While you can count on TCP to provide a reliable byte stream it does not provide the message boundaries. The PDURecord library makes it very easy to work with this. We developed this after our expericence with writing dozens of decoders.

Typically a protocol dissector will use **PDURecord** to create full "messages" from a byte stream and then **SweepBuf** to extract fields from the message.



## PDURecord interface

You need to write a PDURecord "handler" and them pump chunks of bytes into the PDURecord. The framework will call your handler at appropriate times with FULL messages. Lets take a look

### Methods

The following methods are in PDU record

| method | description |
| --- | --- |
| `push_chunk(sequence_no, bytes)` | Push a chunk of payload starting at the sequence number. Repeatedly pushing the same chunk ( `bytes` with the same `sequence_number` ) has no effect. PDURecord is smart enough to recognize overlaps. The only requirement for the caller is you cant push a chunk that will create a hole |
| `want_next(num_bytes)` | The dissector calls `want_next(100)` when it determines that the record boundary is 100 bytes away. So this method creates a PDU from current position to current_position + 100 bytes |
| `want_to_pattern(regex)` | The dissector calls `want_to_pattern("\r\n")` if it determines the boundary is at the next occurrance of \r\n |
| `skip_next(num_bytes)` | The dissector calls `skip_next(10000)` if it determines the record boundary is 10000 bytes away but we are not interested in this message. So your dissectors `on_message` will not be called. This is useful when you are not interested in some types of messages such as TLS Encrypted Application Data records |
| `abort` | Signal that we are no longer interested in this flow | 



### PDU Dissector

Your handler looks like this

````lua

local MyFixDissector  = {

  -- how to get to the end of next record 
  -- 
  what_next =  function( tbl, pdur, swbuf)


  end,


  -- handle a full record
  --
  on_record = function( tbl, pdur, strbuf)


  end,


}

-- state 
new_fix = function()
    local p = setmetatable(  { state='init'},   { __index = MyFixDissector})
    return p
end

````


The two functions are

| function | params | description |
| --- | ----| --- |
|`what_next`| `tbl, pdur, swbuf` | Called when PDURecord wants to know where the next message boundary is.  `tbl` gives you accesss to the state variables you need to keep,  `pdur` the PDURecord object, `swbuf` = Sweepbuf object representing the payload we have so far.  Call `pdur:want_next()` or other methods from here. |
|`on_record`| `tbl, pdur, strbuf` | Called when a complete message is extracted.  `strbuf` is a string buffer containing the full message |


### Callback what_next

The `what_next()` function is where all the magic happens. It is called by the PDURecord to detemrine where the next record is. Your goal is to detect the record end using the header parts of the record in the swbuf variable and return it. 




## Example

The SSH protocol has the 1st record delimited by `\r\n\` and the other records delimited by a 32 bit length. (Simplifying here a a bit). So your dissector would be like


````lua
 -- how to get the next record 
  -- SSH2.0 is simple - 
  --  1. the first pkt looks for \r\n
  --  2. the others Up-Until the NEW KEYS are length
  --  3. after that *-etm HMACs have clear text length, others dead-end 
  -- 
  what_next =  function( tbl, pdur, swbuf)
    if tbl.ssh_state  == "start"  then
      pdur:want_to_pattern("\n")
    else
      pdur:want_next(swbuf:u32() + 4)
    end
  end,

  on_record = function(tbl,pdur,swbuf)
  	if tbl.ssh_state=="start" then
  		print('we got first ascii record of ssh client/server id string')
  		tbl.ssh_state=="negotiate"
  	end

  	-- do something with the record

  end,

````



Note here techniques 

-  maintain a state ; you will need to do this because this pattern is very common in network protocol dissection. 
-  based on state - call  `want_next()` or `want_pattern()`  on PDURecord 
-  when you get a `on_message(..)` adjust the state if required, if you want to use someother method to determine the record boundary.


#### Full example 

See our full APP [SSH Analyzer](https://github.com/trisulnsm/apps/tree/master/analyzers/ssh-alert)

