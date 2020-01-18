Trisul Scripts
================


Repository of small but powerful network and security monitoring scripts for use with Trisul Network Analytics (trisul.org) 



How to run these samples ?
-------------------------

You need to have :

- A running instance of Trisul 
- Git clone this repo, if you havent already `git clone https://github.com/trisulnsm/trisul-scripts.git ` 
- Go to the `trisul-scripts/helloworld` directory
- Run the hello.rb script ( ruby hello.rb 192.168.1.222 ) replace that IP with your Trisul's IP. The password for the private key file is `client` 

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

