Techniques
==========

Scripts demonstrating techniques for using the LUA API


1. re2http.lua 
   -----------

   Uses RE2 regex to build a completely customizable HTTP logger, like those found in NGINX or APACHE.
   
   Demonstrates the following

   1. How to use the onload(..) and onunload(..) to open and close output files
   2. Using precompiled regexes 
   3. How to use a random output file name because there may be multiple instances of the plugin active
      at the same time. 



