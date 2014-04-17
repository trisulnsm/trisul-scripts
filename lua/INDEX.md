LUA API  - samples
------------------

LUA allows you to plug into various points in the Trisul C engine. 


This directory consists of a number of working samples.


All the features of native C plugins are automatically available
to the LUA Plugins as well. These include statistical sketching (top-n, cardinatliy) traffic monitoring flow taggers, packet searches etc.

File | Path |Description
--- | --- |---
socialalert.lua|alerts|Generates an ALERT when you access  social networks like Facebook,Twitter 
tcphdr.lua|buffer|Prints the TCP header  - does not actually meter anything 
rstcounter.lua|counters|Count Number of RST packets seen
hello.lua|hello|Basic working script, just prints hello
hello2.lua|hello|Calls a bunch of methods on T.host inside onload
httpsvr.lua|httpserver|Counts HTTP traffic per HTTP Server
pktlen.lua|packetlen|orking sample adds a new counter group called "Packet Length"
ac-httplog.lua|techniques|HTTP Logger , this time using Aho-Corasik T.ac(..) 
httplog.lua|techniques|A customizable HTTP logger, correlates requests and responses
queue.lua|techniques|simple way to implement queues and double queues
re2http.lua|techniques|Use RE2 regex to capture select HTTP headers and log them
tagflow.lua|techniques|Tags user agent with old java verson
