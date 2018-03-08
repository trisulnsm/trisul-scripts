UA-Parser for Trisul
=====================

User agent parser.

Uses the UA-Parser regex to analyzer HTTP User-Agent strings and generate the following data 

1. Metrics in 3 New Counter Groups ; Browser, Devices, OperatingSystems. The definitions can be found in cg-xyz.lua   
2. A User-Raw Resource in 1 New Resource Group ; Files ua-resource.lua 
3. Tags flows with Browser Strings 
4. Generate EDGE for graph analytics  with Browser,OS,Devices
5. The ** meat of the script ** is in ua-resource-monitor.lua



