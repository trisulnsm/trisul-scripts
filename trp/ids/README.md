Working with IDS Alerts
========================

Scripts dealing with IDS alerts, flows, and packets


## save_pcap.rb

save_pcap.rb demonstrates how you can automate gathering together
context around an alert. This script can be run daily and will
gather all packets in all flows that generated a Severity (Priority) 1 
alert into a single PCAP file.

### Techinques used

* Use QUERY_SESSIONS to retrieve flows by tag
* Working with session_id 
* Retrieving packets for multiple flows 
* Naming the PCAP file as the SHA1 of contents 

Sample run 

````

[nsmeast@localhost helloworld]$ ruby save-pcap.rb  127.0.0.1 12001
Enter PEM pass phrase:
Saved to 5ed6ed34b431a3c253112fa7cefaaa93d6172ef3.pcap



````

