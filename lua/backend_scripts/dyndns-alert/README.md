Dynamic DNS detection
---------------------

Dynamic DNS lets you access your resource using a fixed domain name while your IP is changing. A lot of DDNS is legitimate such as IP cameras and physical security systems, but a lot of it is used for nefarious purposes.  

Presence of dynamic DNS in your organizations traffic definitely warrants a closer look at whats going on.  Think of it is a low cost but essential threat hunting. You can use it to update alerts, enrich other types of data, or just record it in the logs for future data mining.

The Intel is open and  relatively easy to collate. You can get a  list of providers here http://dnslookup.me/dynamic-dns/ - then visit each of the Free providers like Afraid.Org and draw up a list of domains.  The providers usually own the 2LD (or sometimes 3LD) and you get to add the front part.

Here is a script you can use now. 

##### Files

1. dyndns-alert.lua - The Trisul API script
2. dynamic-dns.txt - The intel file - put all the 2LD or 3LD in a file along with source
3. trie.lua - a basic TRIE implementation in lua designed for DNS matching 


## script dyndns-alert.lua

The [resource_monitor script](http://trisul.org/docs/lua/resource_monitor.html) in the Trisul LUA API provides access to the stream of resources extracted by Trisul. In this case, we need to plug into the channel "DNS Resources". 


#### Code guide 

Trisul scripts use general purpose LUA - so there are many ways of checking for a match. The key integration points are the following. 

1. Download the skeleton code for "Resource Monitor" scripts from [skeletons](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/skeletons) 
1. In onload() : we load the Intel into a Trie structure. In trie.lua, we create a simple lookup for DNS partial matches.
2. In onnewresource() : we check if the DNS matches
3. If we detect a Dynamic DNS , we generate a System Alert and add it back to the Trisul pipeline.


### Other things you can do 

In a threat hunting scenario, generating an alert is just one of the many things you can do when you want to flag something.  Here are some of the enhancements you can think of as a homework :)

1. Use the DDNS response IP and then Flag all the IP Flows with a label "DDNS". 
2. Instead of onnewresource(..)  do the checking in onflush(..) if you are okay with 1 Min (max delay)
3. Generate another metric in Trisul for DDNS volume add it to the Aggregates counter group. You can then use advanced metrics like "Dyndns lookups over time" and see if there are any deviations. 

Trisul's real advantage is it enables you to generate and model 2nd order statistics like (3) and use that as key starting points for threat hunting.


##  Install 

See LUA Documentation : http://trisul.org/docs/lua/basics.html#installing_and_uninstalling , put the trie.lua file in the subdirectory called  _helpers_

