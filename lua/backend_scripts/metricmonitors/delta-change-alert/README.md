Technique to detect and alert on DELTA change on any metric
===========================================================

# script mac-traffic-tracker.lua

Give a list of MACs to monitor and the following

````
  mac_table = {
	["00:1C:C0:B9:B9:10"] = {delta=0.5, alert_str="SYSTEMUNDER_TEST_77" , last_val=0, last_val_tm=0} ,
	["00:1B:57:41:71:75"] = {delta=0.5, alert_str="SEMIND_FUTURES" ,      last_val=0, last_val_tm=0} ,
  },
````

1. *delta* : What % delta UP or down do you want to alert on 
2. *alert_str* : Useful string to include with the alert, use an asset name or handler
3. *last_val,last_tm* : leave it at 0



Inserting this script into Trisul Backend LUA will generate an alert whenever the usage (1-min)
goes beyond delta*value_in_previous_inteval.

We have it in production for monitoring steady multicast feed for Financial Market applications.
Works great.




