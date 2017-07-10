ssh passive analysis
====================


Uses the techniques described in [Traffic Analysis of Secure Shell ](https://trisul.org/blog/analysing-ssh/post.html)  to

1. detect successful logins
2. detect keystrokes after a successful login
3. detect SSH Tunnels,  forward or reverse


The files are
- ssh_dissect.lua  -- SSH protocol analyzer 
- ssh-spy.lua -- connects the ssh_dissect.lua into Trisul TCP Reassembly 
- ssh-alert-group.lua -- a new alert group to house the alerts 


The scripts uses the `PDURecord` and `SweepBuffer` helpers from the [BitMaul stream to PDU library](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/bitmaul)





