Techniques
===========


Demonstrates LUA scripting techniques


h3. Single threaded run

The best way to handle flow based states is to run Trisul as 
 - Single Threaded ( for reading PCAP files)
 - Use flow pinning ( for live traffic)

To run Trisul as single threaded for reading PCAP files use the following technique
 - Open trisulConfig.xml 
 - Change the InFlightTokens to 1 




1. re2http.lua
   --------------

   Log HTTP requests and responses

   Demonstates the use of T.re2(). Trisul exports the Google RE2 Regex Library 
   it uses internally to the LUA side. The expressions are precompiled in the 
   onload() function.

   partial_match( ) matches a regex 

   partial_match_c1( ) matches a regex with one capture

   partial_match_c2( ) matches a regex with two captures

   Next steps : Correlate requests and responses

  
2. httplog.lua
   -----------

   A fully customizable request-response correlating HTTP logger

   The re2http.lua sample logged requests and responses on separate lines. This scripts
   uses the flow:id() method to correlate responses to requests and log them on a single
   line.
  
   Also demonstrates the following

   - how you can "include" a Lua file such as queue.lua 

   - opening output log files in a threadsafe way by adding random number

   - timestamping, working with queues, and more

   Next steps : Listen to flow termination event to clean up map and okay garbage collection.


3. ac-httplog.lua
   -----------

   HTTP logger using T.util.ac Aho Corasick tool to locate HTTP headers that need to be logged

   Also demonstrates the following

   - note usage of T.host:id() to get engine ID that is hosting the lua interpreter instance 


4. broadcast-state.lua
   --------------------

   HTTP logger using channel listener technique that broadcasts state updates to particular listeners.
   Note that running this version of httplogger you are losing some logs. Broadcast techniques are 
   best used for signaling messages where there is a time lag between 'signaling' and 'control' 

   Also demonstrates the following

   - note usage of T.host:id() to get engine ID that is hosting the lua interpreter instance 
   - T.host:broadcast technique - not how the id {.. } block as a new attribute called clsid (Class ID )


