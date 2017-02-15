File|Path|Description|
--- |--- |--- |
socialalert.lua|[alerts/socialalert.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/alerts/socialalert.lua)|Generates an ALERT when you access Facebook/Twitter
tcphdr.lua|[buffer/tcphdr.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/buffer/tcphdr.lua)|Demonstrates how you can work with buffer object
my-alerts.lua|[custom_alerts/my-alerts.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/custom_alerts/my-alerts.lua)|Create a new alert group
rstcounter.lua|[custom_counters/rstcounter.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/custom_counters/rstcounter.lua)|Create a new counter group and update the meter
pdf-files.lua|[custom_resources/pdf-files.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/custom_resources/pdf-files.lua)|Create a new resource group
filex_ramfs_basic.lua|[fileextract/filex_ramfs_basic.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/filex_ramfs_basic.lua)|Use of filter(..) to only save text/html content 
filex_stream.lua|[fileextract/filex_stream.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/filex_stream.lua)|File Extraction by lua  using the onpayload(..) streaming interface
filter.lua|[fileextract/filter.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/filter.lua)|Use of filter(..) to only for Javascript
fx_largeimage.lua|[fileextract/fx_largeimage.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/fx_largeimage.lua)| Filter jpeg type and save the file in filesystem if file size is grater then 500000 bytes | 
fx_video_chunk.lua|[fileextract/fx_video_chunk.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/fx_video_chunk.lua)| Save the file in filesystem if content-type is video 
malware-cymru.lua|[fileextract/malware-cymru.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/malware-cymru.lua)|Malware lookup MD5/SHA-1 http://www.team-cymru.org/MHR.html
malware-cymru-alert.lua|[fileextract/malware-cymru-alert.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/malware-cymru-alert.lua)|Malware lookup MD5/SHA-1 and http://www.team-cymru.org/MHR.html generate badfellas alert
save_content_types.lua|[fileextract/save_content_types.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/save_content_types.lua)|Saves all files matching a Content-Type (shockwave\|msdownload\|dosexec\|pdf) | 
save_content_types_sha256.lua|[fileextract/save_content_types_sha256.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/save_content_types_sha256.lua)|saves all files matching a Content-Type (shockwave\|msdownload\|dosexec\|pdf)  and perform a SHA256 hash and feed that back into TRISUL as a 
saveall.lua|[fileextract/saveall.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/saveall.lua)|Used to handle large files and Saves all files into /tmp/trisul_files
sha256.lua|[fileextract/sha256.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/fileextract/sha256.lua)|streaming contents to update the hash
tls-heartbeat-2.lua|[heartbleed/tls-heartbeat-2.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/heartbleed/tls-heartbeat-2.lua)|Detects TLS heartbeats 
httpsvr.lua|[httpserver/httpsvr.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/httpserver/httpsvr.lua)|Counts HTTP traffic per HTTP Server 
barnyard2_unixsocket.lua|[inputfilter/barnyard2_unixsocket.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/barnyard2_unixsocket.lua)|Reads unified2_  structs from barnyard2_ unix_socket
lanlflow.lua|[inputfilter/lanlflow.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/lanlflow.lua)|custom input filter for Trisul to process the sample flow DB
purelua_pcap.lua|[inputfilter/purelua_pcap.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/purelua_pcap.lua)
snort_unixsocket.lua|[inputfilter/snort_unixsocket.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/snort_unixsocket.lua)|Listen to alerts from Snort directly and then feed them into  trisul
suricata_eve.lua|[inputfilter/suricata_eve.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/suricata_eve.lua)|listens to eve.json file output by Suricata, decodes the alerts, and pushes them into Trisul Network Analytics
suricata_eve_unixsocket.lua|[inputfilter/suricata_eve_unixsocket.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/suricata_eve_unixsocket.lua)|lsame as suricata_eve.lua file but uses Unix Sockets 
vast.lua|[inputfilter/vast.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/inputfilter/vast.lua)|reads the flow CSV dump in VAST 2013 
ringmark1.lua|[packetstore/ringmark1.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/packetstore/ringmark1.lua)|Control on flow level packet storage
flow_attributes.lua|[reassembly/flow_attributes.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/reassembly/flow_attributes.lua)|Prints HTTP Hosts a flow attribute and value.
ftp.lua|[reassembly/ftp.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/reassembly/ftp.lua)|Listens to FTP Traffic and extracts to /tmp/ftpfiles directory
reass_filter.lua|[reassembly/reass_filter.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/reassembly/reass_filter.lua)|shows how you can use the \filter\ method to control which flows you want to reassemble 
savetcp.lua|[reassembly/savetcp.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/reassembly/savetcp.lua)|save all reassembled TCP stream data into files
tlsalert.lua|[reassembly/tlsalert.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/frontend_scripts/reassembly/tlsalert.lua)|Generates a custom alert when obsolete TLS versions ( < TLS 1.2 ) are seen



