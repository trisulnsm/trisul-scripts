Heartbleed 
==========

Includes detection and monitoring for the heartbleed attack.
The attack itself is a disclosure vulnerability due to a rather 
rudimentary programming error in OpenSSL. For details http://heartbleed.com/


We dont think it is possible to signature match the heartbleed attack because like
the other TLS Content Types (alert, change cipher spec) the heartbeat packet is 
itself encrypted. Our Lua script takes a dramatically simpler approach. If the 
overall request and response sizes do not match, we've got issues ! We dont even
have to open the heartbeat section.

We present two scripts here 
- tls-heartbeat-2.lua  Generate an alert when it sees this kind of mismatch

- tls-monitor.lua This will create long term metering of TLS content types. 
  Trisul's philosophy is to meter as much as possible. We already meter TLS Certs, 
  TLS CAs, TLS Organizations, and Cipher specs natively. This little LUA script adds
  in TLSRecord counter group. If we have this in place...


tls-heartbeat-2.lua
-------------------

Simple script to detect the heartbleed attack. 

This is not signature based, rather just compares the sizes of two consecutive TLS Heartbeat records. If they are both rogue requests, that is still an attack because the TLS RFC 6502 only allows one inflight heartbeat record.


If an attack is detected, this script generates an ALERT, that looks just like a Snort/Suricata alert with its own private SIGID. 



tls-monitor.lua
---------------

Would you like to know if you ever received a heartbeat record in your network? What about other kinds of records like SessionTickets? 

In keeping with Trisul's statistical approach, the heartbleed attack and others like that are an opportunity for you to meter SSL/TLS deeper. Add this little Lua script to the plugins/lua directory to start monitoring TLS Record Types in your Network. 

Go to Retro Counters > Select TLSRec for any period of time to visualize record types.

![Monitor SSL](https://raw.githubusercontent.com/vivekrajan/trisul-scripts/master/lua/heartbleed/tlsrec2.png)


Total number of various types of records, newly spiking record types can call for deeper investigation

![Monitor SSL](https://raw.githubusercontent.com/vivekrajan/trisul-scripts/master/lua/heartbleed/tlsrec1.png)




