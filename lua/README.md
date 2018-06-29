Trisul LUA API Samples
======================

The Trisul LUA API allows you to program the Trisul real time network analytics engine.

This repository contains a number of working samples demonstrating various types of scripts.

Where do I start?
-----------------

The first three places  you need to know are : 

1. The [Trisul LUA API Documentation](http://www.trisul.org/docs/lua)
2. The `tutorials` directory contains scripts that are used in the [Trisul LUA tutorials](http://www.trisul.org/doca/lua/tutorial1.html)
3. The `skeletons` directory contains well commented skeletons of various types of scripts you can use to get started.


### Directories

Next, the actual scripts are split into two directories. 

In Trisul, LUA scripts that run on the "fast" path are called Frontend scripts and those that run on the "metric streams" are called Backend scripts. For more see [Frontend vs Backend](http://www.trisul.org/docs/lua/basics.html#frontend_and_backend_scripts) 

The directories here are organized that way 

1. Directory `frontend` - **Frontend scripts**  Contains samples of frontend scripts. Examples are TCP Reassembly, HTTP File Reconstruction etc
2. Directory `backend` - **Backend scripts** Contains samples of flow monitors, passive DNS, etc


Getting help
------------

Create an issue here on Github 
