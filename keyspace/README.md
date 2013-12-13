Active keys in a range
======================

The KEYSPACE_REQUEST command is used to retrieve the active keys in a range.

For example : This request can be used to retrieve all IPs seen in the 10.x.x.x private IP range.
The key space is this case is  10.0.0.0 to 11.0.0.0.


### TRP Messages used

The above script uses the following TRP Messages

1. [KeySpace](http://trisul.org/docs/ref/trpprotomessages.html#keyspace)  - to retrieve keys in a range 


### Sample run


The following run displays the all IPs seen in the 192.168.0.0/16 range
Note that "Hosts" counter group has the GUID {C-4CD...} and the keys are in Trisul Key Format.

The active_keys2.rb script extends the base script to convert human readable keys into Trisul Key Format. We've separated the two scripts to highlight use of the KeySpace message.


```
[vivek@longdog trp]$ ruby active_keys.rb 192.168.1.22 12001 {4CD742B1-C1CA-4708-BE78-0FCA2EB01A86} C0.A8.00.00 C0.A9.00.00
Enter PEM pass phrase:


```

