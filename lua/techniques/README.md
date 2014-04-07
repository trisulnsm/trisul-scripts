Techniques
===========


Demonstrates LUA scripting techniques


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


