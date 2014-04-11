# TRP Scripts


  File Name | Path | Desciption
  --- | --- | ---
  search_fqdn.rb|apt1-detect|Runs a set of FQDNs past all names known by Trisul 
  search_fqdn_adv.rb|apt1-detect|1. Runs a set of FQDNs past all names known by Trisul <br/>  2. Prints not just the ResourceID but actual contents of resource
  search_keyspace.rb|apt1-detect|Search for matches in key space
  search_md5.rb|apt1-detect|Search *ALL* HTTP objects for matching MD5
  search_md5_adv.rb|apt1-detect|1. Search ALL HTTP objects for matching MD5 <br/> 2. Print session details <br/> 3. Get PCAP of sessions with matching MD5 content
  search_text.rb|apt1-detect|Search all flows (incl HTTP) for a text pattern
  certx.rb|cert-extract|Print Cert Chains from particular IP
  cginfo.rb|cginfo|Prints information about given Counter Group on a trisul instance
  cginfoall.rb|cginfo|Prints information about all counter groups
  ftracker.rb|elephantflows|Flows that transfer huge amounts of data <br/># - These flows are tracked by Trisul as Tracker #0
  flows_2.rb|flows|Search flows by any two combinations [IP or PORT] [IP or PORT]
  query-by-flowid.rb|flows|Query by flow id , every flow in Trisul has a unique id of the form slice:session. Eg 1:999 
  query-flow.rb|flows|Print all the matching flows by simple query
  daypcaps.rb|getpcap|get all pcaps in a given month, one file per day. <br/>  save on server
  getpackets.rb| getpcap|Save all packets in timeframe to a PCAP file
  getpackets2.rb|getpcap|Save all packets between two days to a PCAP file on the server. </br> his version allows you to enter a from date and to date
  getvolume.rb|getvolume|Get last 24-hours volume of traffic for any item
  hello.rb|helloworld|connect to a Trisul sensor and print sensor ID
  hourlystats.rb|hourlystats|Print hourly statistics of any key for any counter
  hourlystats2.rb|hourlystats|Same as hourlystats.rb but uses the volumes_only flag to retrieve totals for a time window, rather than raw data points
  checknotary.rb|icsissl|Run all certs in past 24 hrs past  the ICSI Certificate Notary
  insecure_hello.rb|insecure|Plain TRP connection, not protected by  TLS auth and privacy features
  iocsweep.rb|ioc-sweeper|Consume an Intelligence feed in OpenIOC format then automatically scan past traffic for matches for network based indicators
  active_keys.rb|keyspace|Print all active keys in given range
  active_keys2.rb|keyspace|Print all active keys in given range.accepts  human readable ranges ( 192.168.0.0 instead of Trisul format C0.A8.00.00)
  toppers.rb|toppers|Prints topper for the particular counter group for any  meter in specified time range
  youtube_titles.rb|youtube|Save PCAPs of all YouTube videos in last 24 hours . Change the file name of each video to the Title of the video |
  youtube_vids.rb|youtube|Save PCAPs of all YouTube videos in last 24 hours|





