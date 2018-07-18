Simplest script - hello world 
=============================

Sends a simple HelloRequest to the TRP Server and prints the output.
[TRP Documentation](https://trisul.org/docs/ref/trpproto.html) 


## How to get the server endpoint?

Connect to the Trisul Domain from the cli and type the following 

the **endpoints_query** port is the server port. 

````
trisul_hub:unpl-seco-16-prod(domain0)> show config default@hub0

node                   hub0
context_name           default
endpoints_flush        tcp://192.168.2.99:13000
endpoints_flush        tcp://192.168.2.99:13001
endpoints_query        tcp://192.168.2.99:13004
endpoints_pub          tcp://192.168.2.99:13002
endpoints_pub          tcp://192.168.2.99:13003

layer                  probe
0                      probe0              
1                      probeWEST           
3                      probeEAST00         
--------------------------------------------------------------
trisul_hub:unpl-seco-16-prod(domain0)> 

````


How to run
----------


hello.rb  <zmq-trp-server-endpoint> 

````
ruby hello.rb tcp://192.168.1.222:13004 

````


