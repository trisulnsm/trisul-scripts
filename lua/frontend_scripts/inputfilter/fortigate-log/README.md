# Fortigate-Log :  This input filter processes Fortigate logs on UDP 


## Running

Download the two lua files to `/usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua`

Then run the following command 

```
trisul -demon /usr/local/etc/trisul-probe/domain0/probe0/context0/trisulProbeConfig.xml \
     -mode lua \
	    -in /usr/local/var/lib/trisul-probe/domain0/probe0/context0/config/local-lua/fortigate-log.lua
```



