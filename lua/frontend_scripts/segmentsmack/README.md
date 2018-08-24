SegmentSmack detector
=====================

A remote DoS attack vulnerability against the TCP/IP stack in the Linux Kernel was made public recently as CVE-2018-5390. 

The official description of the vulnerability [cve.mitre.org](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-5390)
> Linux kernel versions 4.9+ can be forced to make very expensive calls to tcp_collapse_ofo_queue() and tcp_prune_ofo_queue() for every incoming packet which can lead to a denial of service.


We just put together a Trisul script quickly as a proof-of-concept to see if we can support security by segment level traffic analysis. 


## SegmentSmack 

The TCP implementation in linux maintains an internal data structure to hold out-of-order packets. In the normal case, packets can arrive slightly out of order and thereby create "holes" in the TCP stream. The datastructure holds these packets and eventually the "holes" are filled by late packets. Then they coalesce the packets into a chunk and pass it up. 

The SegmentSmack attack works by transmitting tiny TCP packets within the receive window but completely out of order. Since each packet introduces a new hole instead of closing one, the process of coalescing the packets always fails. This waste of CPU is the exploit.  We are guessing the packets have to be very small because you need a lot of packets within the window, secondly a large number of big size packets will place a high bandwidth requirement on the attacker and can also trigger various volume based DDoS mechanisms. 


## How this script works

This script plugs into the [TCP protocol layer of Trisul](https://www.trisul.org/docs/lua/simple_counter.html)  and keeps track of out-of-order segments.  To reduce the memory and processing requirements, we dont keep the actual _segments_ and _holes_ per flow, rather just track if an incoming segment has the expected sequence number.  We then declare an alert if the following condition is met

If the flow is large enough and the ratio of out-of-order segments to the the in-order segments > 0.90 then we declare an alert. These cutoffs are seemingly reasonable values, you can tweak them. 


````lua
-- Push  an alert into Trisul  
-- for this attack to be worthwhile , need atleast 1000 segments 90% of which are outof order 
if tbl.out_of_order_segments + tbl.in_order_segments > 1000 and 
   tbl.out_of_order_segments / tbl.in_order_segments > 0.90 then 
   -- alert goes off 
   engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}", -- GUID for 'User Alerts' group
 	 layer:packet():flowid():id(),   -- flow ID
	 "POTENTIAL-SEGMENTSTACK",       -- alert key , think of this as a SigID   
	 1,                              -- priority
	 "Unusual out of order order segments detected : ooo="..tbl.out_of_order_segments.." io="..tbl.in_order_segments   
	)
end 

````


## DevZone

We have an article on Trisul DevZone which talks about the feasibilty of doing per-packet traffic monitoring using LuaJIT. 

