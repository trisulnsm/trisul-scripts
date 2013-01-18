Search and pull out Youtube videos
==================================


This script will save all YouTube videos seen by a Trisul sensor.

Written in Ruby with the trisulrp (http://trisul.org/docs/trp/)  gem.

There are two scripts 

#### 1. youtube_vids.rb    Get PCAP of Youtube videos
   Connect to a Trisul Sensor, search for video streams, download PCAPs 
   of these video streams. 


#### 2.  youtube_titles.rb   Dump the video file and rename with Title 
   Load the PCAP into Unsniff and dump the playable video file
   Use Unsniff to get the 'HTTP referer' for each video stream, 
   Get the referrer page PCAP
   Dump the referrer HTML using Unsniff API
   Load the referred HTML using Nokogiri and search for the <title>
   Change the name of the video file to the "title"


Demonstrates the following
--------------------------

- Using the Trisul Remote Protocol (TRP) 
- How to search for URLs matching a certain pattern
- Extract PCAPs for matching URLs
- Using the Unsniff Network Analyzer API to parse HTTP 
- Dumping Videos in WEBM and FLV format using Unsniff API

