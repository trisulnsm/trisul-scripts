# TRP samples for python

TRP samples for python to get data from trisul server over zmq.

## Getting Started

These instrctions will get you to run the python trp  scripts.

### Prerequisites

```sh
$ protoc trp.proto --python_out=.
$ sudo apt-get install python-pip
$ sudo pip install protobuf
$ sudo apt-get install python-zmq
```

##  Running the tests

```sh
  $  python  counter_group_topper_request.py ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0 {889900CC-0063-11A5-8380-FEBDBABBDBEA} 0
```sh