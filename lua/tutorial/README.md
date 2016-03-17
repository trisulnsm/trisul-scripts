LUA Scripting Tutorials
-----------------------

These scripts are to be used along with the "Getting Started" LUA Tutorials on the 
documentaton page at http://trisul.org/lua/ page


hello.lua  Hello World with Trisul and LUA
------------------------------------------

(Part of Tutorial 1) 

This script should be the very first LUA script that you write. It demonstrates the following

- Basic skeleton structure of a LUA script
- onload and onunload functions
- Where to place the LUA scripts 
- Running a PCAP file and printing to console and log file 

This tiny script is a great starting point.


pktlen.lua Packet Length Metering
----------------------------------

(Part of Tutorial 2) 


A real useful metrics script. This script looks at streaming network traffic and 
computes a packet length distribution. The traffic is classified into

Packet lengths
1500            
1000-1500
500-1000
200-500
100-200
0-100


THis demonstrates

- Creating a new counter group called "Packet Length"
- Using Keys - the string "1000-1500" is a key used to identify metrics for this bucket
- Using LUA Objects  "Layer" "Packet" and "Buffer"
- Viewing the results in web trisul 





