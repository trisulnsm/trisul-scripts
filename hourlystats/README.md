Hourly Statistics of any item
==================================


This script allows you to draw a neat hourly chart of traffic of any item.

- hourlystats.rb : gets the raw timeseries data (30s) and adds it up 
- hourlystats2.rb : uses the volumes_only flag to avoid getting raw timeseries


```
[vivek@localhost trp]$ ruby hourlystats.rb  192.168.1.22 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050 0
Enter PEM pass phrase:
    Day/Hour|     03:00|     06:00|     09:00|     12:00|     15:00|     18:00|     21:00|     00:00|
  2013-01-24|         0|         0|         0|  22293120|  65219070|  15995910|         0|         0|
  2013-01-23|         0|         0|         0|         0|         0|         0|         0|         0|
  2013-01-22|         0|         0|         0|  52982520|  63958710|  94162590|  29339940|         0|
  2013-01-21|         0|         0|         0|         0|         0|         0|         0|         0|
  201

```

You need to know the GUID, Meter No, and Key of any item.


GUID and meters are available from  Customize -> Meters

The Key is available from the key dashboard. Search for any item in the search box and get the key.


Some common keys 
----------------

To get HTTP Total Volume
```
[vivek@localhost trp]$ ruby hourlystats.rb  trisul-ip 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050 0
```

To get HTTP Into Your Network (use meter id 2 instead of 0: the last parameter). See Customize > Counters > View Meters 

```
[vivek@localhost trp]$ ruby hourlystats.rb  trisul-ip 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050 1
```

Traffic transmitted by IP 192.168.1.8. Search and the key is C0.A8.01.08 and Guids from View Meters

```
[vivek@localhost trp]$ ruby hourlystats.rb  trisul-ip 12001 {4CD742B1-C1CA-4708-BE78-0FCA2EB01A86} C0.A8.01.08 1
```
