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




