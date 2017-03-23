Trisul LUA API Samples
======================

The Trisul LUA API allows you to customize and build upon the Trisul real time network analytics engine.

This repository contains a number of working samples demonstrating various types of scripts.

Where do I start?
-----------------

The first three directories you want to check out  are 

1. The first resource to be familiar with is the [Trisul LUA API Documentation]http://www.trisul.org/docs/lua 
2. The `tutorials` directory contains scripts that are used in the [Trisul LUA tutorials]http://www.trisul.org/doca/lua/tutorial1.html
3. The `skeletons` directory is very important - you can just copy well commented skeletons of various types of scripts and get started. 

Next, the actual scripts are split into two directories. 

In Trisul, LUA scripts that run on the "fast" path are called Frontend scripts and those that run on the "metric streams" are called 
Backend scripts. The directories are organized that way 

1. Frontend scripts in directory `frontend` - contains samples of frontend scripts. Examples are TCP Reassembly, HTTP File Reconstruction etc
2. Backend scripts in directory `backend` - flow monitors, passive DNS, etc


Getting help
------------

Create an issue here on Github 
