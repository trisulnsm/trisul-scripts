# TRP samples for python

How to use Python to query Trisul data using TRP (Trisul Remote Protocol). 
https://www.trisul.org/docs/trp/index.html

TRP is a query/response API that uses the following technologies
1. ZeroMQ for communication 
2. Google Protocol Buffers for the API messages 


### Prerequisites

1. Download trp.proto from https://raw.githubusercontent.com/trisulnsm/trisul-scripts/master/trp/trp.proto
`curl -O https://raw.githubusercontent.com/trisulnsm/trisul-scripts/master/trp/trp.proto`


2. Then run the following steps to create a run environment

```sh
$ protoc trp.proto --python_out=.
$ sudo apt-get install python-pip
$ sudo pip install protobuf
$ sudo apt-get install python-zmq
```

##  Running the samples

To run a sample just type.

```sh
  $  python  cginfo.py ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0 
```

The string `ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0` is the ZMQ connection string where the Trisul TRP server is running on. To find out the connection string the default context type. 

```sh
trisulctl_hub show config default
```


Another example.


```sh
  $  python  counter_group_topper_request.py ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0 {889900CC-0063-11A5-8380-FEBDBABBDBEA} 0
```
