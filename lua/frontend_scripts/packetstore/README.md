Fine control of PCAP storage 
======


Also see  : [packet_storage documentation](http://trisul.org/docs/lua/packet_storage.html) 


Control packet storage on a per-flow basis.

1. You get asked ONCE at start of a flow how you want to handle packet storage
2. Trisul applies the rule to all packets in that flow
3. Unlike *BPF* or hardware level filters - the packets are fully analyzed, they just arent stored. 


Streaming Budget
------

Since the _new flow_ rate is orders of magnitude lesser than the _packet rate_  you have some headroom for some computations. 


1. No network IO 
2. Budget typically less than 1 sec per decision
3. That is usually plenty to lookup a table with millions of entries 
4. Go to Dashboard > System Performance > Packet Drops to see how system is performing 


Samples
=======

1. skip_ssh.lua  -- why waste 100s of GB of disk by storing SSH traffic? this simple script skips that 
