Backend scripts
===============

Backend scripts listen on metrics and artifact streams and then generate further metrics or feedback into the processing. 

Here are a list of backend script types.  Clicking on the link will open the relevant LUA Documentation 

1. [engine_monitor](http://trisul.org/docs/lua/engine_monitor.html) -- called before and after every stream snapshot interval (1 min by default) 
2. [cg_monitor](http://trisul.org/docs/lua/cg_monitor.html) -- metric stream per counter group 
3. [sg_monitor](http://trisul.org/docs/lua/sg_counter.html) -- Flow metrics | On new flow, when flow is flushed,  |
4. [alert_monitor](http://trisul.org/docs/lua/alert_monitor.html) -- alerts 
5. [resource_monitor](http://trisul.org/docs/lua/resource_monitor.html) -- Metadata Resources HTTP requests, DNS events, TLS, File hashes stream|
6. [fts_monitor](http://trisul.org/docs/lua/fts_monitor.html)  -- Full text document. TLS Certificates, DNS Domains, HTTP Headers, etc 
7. [flow_tracker](http://trisul.org/docs/lua/flow_tracker.html ) -- Create your own custom flow tracker - top-K flow snapshots |


Where to start ? 
-----------------

1. The simplest backend scripts are probably those that listen to particular stream types ( think of them as 'topics') look at the content and just print them. You can start with `flows/sg1.lua`. 
2. If you are interested in exporting Trisul flow data to third party systems. Check out `elasticsearch` 


Skeletons
---------

If you want to get started and write your own scripts - you can copy a from the `skeleton` directory one level down.



Featured samples
================


File|Path|Description|
--- |--- |--- |
print_alerts.lua|[alerts/print_alerts.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/alerts/print_alerts.lua)|Print all Badlist alerts
print_alerts2.lua|[alerts/print_alerts2.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/alert/print_alerts2.lua)|Print all alerts that matched name External IDS alert group 
dyndns-alert.lua|[dyndns-alert/dyndns-alert.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/dyndns-alert/dyndns-alert.lua)|Add alert when Dynamic DNS is resource is accessed
es_curl_flow.lua|[elasticsearch/es_curl_flow.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/elasticsearch/es_curl_flow.lua)|Send trisul flow to Elasticseach using CURL
es_socket_flow.lua|[elasticsearch/es_socket_flow.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/elasticsearch/es_socket_flow.lua)|Send trisul flow to Elasticseach using lua socket
sg1.lua|[flows/sg1.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/flows/sg1.lua)|Print flow id for a new flow
sg2.lua|[flows/sg2.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/flows/sg2.lua)|Writes in flow count in a file
sg3.lua|[flows/sg3.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/flows/sg3.lua)|Writes the flow in a file
ssh_alerts.lua|[flows/ssh_alerts.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/flows/ssh_alerts.lua)| Add a blacklist alert when ssh flow volume is less then 1000 bytes
ocsp_check.lua|[fts/ocsp_check.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/fts/ocsp_check.lua)| Verifiy a certificate against OCSP(Online Certificate Status Protocol)
ocsp_check_aysnc.lua|[fts/ocsp_check.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/fts/ocsp_check.lua)| Verifiy a certificate against OCSP(Online Certificate Status Protocol) without affecting packet process pipeline
cgmon.lua|[metricmonitors/cgmon.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/metricmonitors/cgmon.lua)|Monitor counter group activity
cgmon_2.lua|[metricmonitors/cgmon_2.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/metricmonitors/cgmon_2.lua)|Monitor counter group activity onupdate
cgmon_3.lua|[metricmonitors/cgmon_3.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/metricmonitors/cgmon_3.lua)|Counter group activity topper flush
filehash.lua|[resources/filehash.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/resources/filehash.lua)|Print MD5 File Hashes resources
printcertchain.lua|[resources/printcertchain.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/resources/printcertchain.lua)|Print SSL certifiace chian
sha256_x509.lua|[resources/sha256_x509.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/resources/sha256_x509.lua)|save certificates to filesystem and feed back the new SHA256 certificate hash into Trisul resources pipelines
ssl.lua|[resources/ssl.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/resources/ssl.lua)|Print SSL resouces
snmp_cg.lua|[snmp/snmp_cg.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/snmp/snmp_cg.lua)|Create new counter group for snmp
snmp.lua|[snmp/snmp.lua](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/backend_scripts/snmp/snmp.lua)|query SNMP and feed counters into Trisul
