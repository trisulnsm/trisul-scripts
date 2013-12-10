Get toppers for any counter group and meter 
===========================================

The COUNTER_GROUP request is used to retrieve the toppers in any counter group
for any meter.

Trisul has an ever expanding list of counter groups and meters.

To see the current list 
- Login and navigate to Customize -> Counters -> Meters
- To see common counters and meters - check "Well known GUIDs" at http://trisul.org/docs/ref/guid.html


The following run displays the top Apps counter group, meter 0.
Note that "Apps" counter group has the GUID {C-51...} and meter 0


```
[vivek@longdog trp]$ ruby toppers.rb 192.168.1.22 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} 0
Enter PEM pass phrase:

Counter Group = {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}
Meter = 0

Key = SYS:GROUP_TOTALS Label = SYS:GROUP_TOTALS  Metric= 65541000
Key = p-0050 Label = http  Metric= 38824800
Key = p-01BB Label = https  Metric= 25761900
Key = p-0035 Label = domain  Metric= 718800
Key = p-03E1 Label = imaps  Metric= 93900
Key = p-076C Label = ssdp  Metric= 71400
Key = p-146C Label = p-146C  Metric= 35100
Key = p-000D Label = daytime  Metric= 12600
Key = p-0016 Label = ssh  Metric= 10500
Key = p-0043 Label = bootps  Metric= 4200

```


## A word on metrics

If you see the topper.rb code we multiply the "metric" field in the response by 300 or topper_bucket_size. This is because the metric returned for Stat 0 is Bytes/sec to convert it into volume we multiply by topper bucket size - default is 5 min or 300 sec.

