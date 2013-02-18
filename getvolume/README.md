Get volume of any counter item 
==============================

How much HTTP data was transferred in last 1 week ? 
This script will help you answer volume based questions like the above 


This script demonstrates the following

1. How to find out the bucket size (resolution) of counter groups
2. How to retrieve and calculate total volume 


The following run prints HTTP volumes in past 24 hours.

Note that HTTP is identified by the counter group {C-51...} and key p-0050 

```
 $ ruby ../trisul-scripts/getvolume/getvolume.rb 192.168.1.22 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050
 Enter PEM pass phrase:
 Volume of Meter 0 = 157639740 bytes  
 Volume of Meter 1 = 840 bytes  
 Volume of Meter 2 = 144789000 bytes  
 Volume of Meter 3 = 12846390 bytes  
 Volume of Meter 4 = 183090 bytes  
 Volume of Meter 5 = 0 bytes  

```
