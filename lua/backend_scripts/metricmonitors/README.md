Metric Monitors 
===========


Metric monitors dont work with packets/ flows but rather with 
streaming metrics. You can monitor either the raw metric 
updates (1sec latency) or keep track of processed and aggregated
metric streams 



1. cgmon.lua
   --------------

   Monitors metric being streamed out to DB from a counter group 

  
2. cgmon-2.lua
   -----------

   Monitors real time (1s) streaming updates to counter group  


3. cgmon-3.lua
   -----------

   Monitors Topper Sketches as they are streamed out to DB 




