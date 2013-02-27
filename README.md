Trisul Scripts
==============

Ready to use scripts for network monitoring, forensics, and security.

How to run these samples ?
-------------------------

You need to have :

- A running instance of Trisul 
- Download the sample client certificate + private key file

## Getting started
Complete instructions are in the "Step by step guide" http://trisul.org/docs/trp/trpgemsteps.html


The NSM strategy followed by Trisul is 
* Big picture and zoom out with Trisul 
* Content, protocol and zoom in  with Unsniff

### 1. Network Security Monitoring using Trisul 

Search traffic, flows, alerts, resource, and packets. Analyze patterns 
isolate flows and pull out raw packets in PCAP format. This is a fast
analysis designed to narrow down the info required for further processing.

You will be using Ruby along with the Trisul Remote Protocol API (http://trisul.org/docs/trp/ ) 

### 2. Content analysis with Unsniff

Once you have the packets, you can use Unsniff Network Analyzers scripting
abilities to extract content, look into protocol fields, search and filter for 
specific things. This is a deep forensics stage designed to carve out
files and other content. 


Ruby with Unsniff Network Analyzer API ( http://www.unleashnetworks.com/unsniffwiki/docs/doku.php?id=start ) 

*Note* Scripts using the Unsniff API run only on Windows systems.

