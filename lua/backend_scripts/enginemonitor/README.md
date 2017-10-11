Engine-Monitor scripts
======


Scripts that run at start and end of each stream window.  

See (Engine Monitor API)[https://www.trisul.org/docs/lua/engine_monitor.html]


>> Like all Backend Scripts you can install and uninstall and edit script on a Live system. 

Two scripts are included here.


1. snmp.lua : Simple SNMP poller that adds metrics for specific ports (hardcoded in lua script)
2. snmp_port_bw.lua : A more sophisticated version that reads a SQLITE database for ports, agents, and community (SNMPv2)


Usage
=====

Easiest way : Just copy the scripts to the `local-lua` directory on the probe. The directory is typically at `/usr/local/var/lib/trisul/domain0/probe0/context0/config/local-lua` 

For other deployment options see ("Installing LUA Scripts")[https://www.trisul.org/docs/lua/basics.html#installing_and_uninstalling]