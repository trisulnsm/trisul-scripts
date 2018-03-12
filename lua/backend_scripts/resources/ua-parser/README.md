UA-Parser for TrisulNSM
=====================

User-Agent strings are notorious for minor variations that make it hard to use them to categorize browsers, devices, and OS.  The [UA-Parser Core](https://github.com/ua-parser/uap-core) project maintains a giant Regex file that you can use to extract these elements.


ua-resource-monitor.lua
------------------------

This is a TrisulNSM Lua [resource_monitor](https://www.trisul.org/docs/lua/resource_monitor.html) script that plugs into the "User-Agent" resource stream and uses the regular expressions to search for a match. 

The working is quite straightforward.

1. onload() : load all 3 categories of regexes (Browser,OS,Device) and their replacements using the RE2 regex facility provided by Trisul LUA API.  Alternately you can port the entire UA-Parser regex into LUA regex format. 
2. onflush() : as each resource is flushed scan the regexes for a match. 
3. Perf: At end of every success, sort the regexes so most matches regexes come to the top. 


Analytics
----------

###  New metrics and resources

Create these new analytics items

1. cg-browser.lua :  A new browser counter group with Bottom-K and Top-K to track hits.
2. cg-os.lua : Operating system
3. cg-device.lua : Device 
4. ua-resource.lua : A new resource group to store User-agent strings. Think of this as Logs. 
5. ua-extractor.lua : Pull out User-Agent resources from HTTP analysis. 


### Generate analytics

If you find a match, update the following analytics items 


1. Add Metrics in 3 New Counter Groups ; Browser, Devices, OperatingSystems. 
2. Tags IP flows with browser info. This allows you to do queries like  "show all Chrome/44 flows"
4. Generate EDGE for graph analytics from  Browser,OS,Devices


Install
--------

Step 1 : Simplest way is to copy all the files in this directory into the _Context Local_ Lua directory on the Probe node.

````
cd /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua
cp *.lua .

````

Step 2 : Next copy the `regexes.yaml`  file into /tmp


Restart the probe.  You're done. 



tinyyaml.lua
------------

Thanks to tinyyaml https://github.com/peposso/lua-tinyyaml/blob/master/tinyyaml.lua  for YAML parsing in LUA. Otherwise we'd have had to use FFI into C-land. 