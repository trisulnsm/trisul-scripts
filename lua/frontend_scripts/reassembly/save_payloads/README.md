savetcp.lua
===========

Saves TCP Payloads into separate files.



How to run
----------

Save the lua file into [one of the directories](https://www.trisul.org/docs/lua/basics.html#installing_and_uninstalling)  Trisul will search for  Lua scripts.

1. Run over a PCAP file


````bash

cp savetcp.lua /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua 

trisulctl_probe testbench run /home/mgilcl/pcaps/upload.tcpd

````

Then you get the payload files in `/tmp`


````bash

mgill@mgill14$  ls -1 /tmp/
/tmp/payloads_06A:C0.A8.01.0B:p-8050_A9.2C.A2.C0:p-01BB_0
/tmp/payloads_06A:C0.A8.01.0B:p-8050_A9.2C.A2.C0:p-01BB_1
/tmp/payloads_06A:C0.A8.01.0B:p-8074_A9.2C.A2.C0:p-01BB_0
/tmp/payloads_06A:C0.A8.01.0B:p-8074_A9.2C.A2.C0:p-01BB_1
/tmp/payloads_06A:C0.A8.01.0B:p-820D_D8.3A.C4.2E:p-01BB_0
/tmp/payloads_06A:C0.A8.01.0B:p-820D_D8.3A.C4.2E:p-01BB_1

````

* _0 contains payloads in  IN direction
* _1 for OUT direction 




