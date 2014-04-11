Insecure connection to Trisul
=============================

*Not recommended* unless you really need it for some reason.

You can connect to Trisul without TLS or client certificates in the 
following manner.

### On the Trisul server

1. Edit the [trisulConfig.xml](http://trisul.org/docs/ref/trisulconfig.html#security)  file and set the Security>Protocol to TLS and Security>ClientAuth to FALSE

### On the TRP clients

2. Use the connect_nonsecure(..) method instead of the connect method.


Thats it ! 

#### Note on Access Control
Even though now you have no control over authentication, you can still control which IPs are allowed to connect by editing the Server>ACL items in trisulConfig.xml 


How to run
----------

````
[btwin@localhost trp]$ ruby hello.rb 192.168.1.222
"Connection success"
"SE-LINK"
"Conn-X"
"3.6.1615"



````


