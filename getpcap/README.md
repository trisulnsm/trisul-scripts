Get all packets for a specified timeframe 
=========================================

This script demonstrates the following

1. Get all packets between Sep 20 2013 an Sep 30 2013 

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
