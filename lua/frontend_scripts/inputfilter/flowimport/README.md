Flow Importer library 
=============


General purpose import library to process network flow data.


## Using 

Fill up whatever details you have about the flow record in a LUA table and then called `process_flow()` 

````lua

local FI = require'FlowImporter'

FI.process_flow( engine,  {
     first_timestamp=        <number>,   -- unix epoch secs when flow first seen
     last_timestamp=         <number>,   -- unix epoch secs  when last seen 
     router_ip=              <ipaddr>,   -- router (exporter ip) dotted ip format
     protocol=               <number>,   -- ip protocol number 0-255
     source_ip=              <ipaddr>,   -- dotted ip format
     source_port=            <number>,   -- source port number 0-65535
     destination_ip=         <ipaddr>,   -- dotted ip 
     destination_port=       <number>,   -- source port number 0-65535
     input_interface=        <number>,   -- ifIndex IN of flow 0-65535
     output_interface=       <number>,   -- ifIndex OUT of flow 0-65535
     bytes=                  <number>,   -- octets, 
     packets=                <number>,   -- packets 
     -- optional --                      
     bytes_out=              <number>,   -- octets in Src->Dest diflowtbl.ion
     packets_out=            <number>,   -- packets in Src->Dest diflowtbl.ion
     bytes_in=               <number>,   -- octets in Dest->Src diflowtbl.ion
     packets_in=             <number>,   -- packets in Dest->Src diflowtbl.ion
     as=                     <number>,   -- ASN (0-65535)
     tos=                    <number>,   -- IP TOS 
})


````


