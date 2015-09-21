#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Print all active keys in given range and time interval 
#
# This is an advanced version of active_keys.rb 
# 	1. accepts  human readable ranges ( 192.168.0.0 instead of Trisul format C0.A8.00.00)
# 	2. interprets and prints the keys 
#
#
require 'trisulrp'

USAGE = "Usage : ruby active_keys2.rb ZMQ_ENDPOINT CGGUID KFROM KTO \n"\
        "Example : 1) ruby active_keys2.rb tcp://localhost:5555 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0000 p-FFFF\n"\
        "          2) ruby active_keys2.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}  p-0000 p-FFFF"


unless ARGV.size == 4
  abort USAGE
end

#Get ZeroMQ end point
zmq_endpt = ARGV[0]

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 86400
# arguments
cgguid = ARGV[1]

# we use the make_key helper function to convert human to key format 
from_key = make_key(ARGV[2])
to_key = make_key(ARGV[3])


# space message 
space = TRP::KeySpaceRequest::KeySpace.new( :from => from_key , :to => to_key)


# Request 1 : for active keys 
# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::KEYSPACE_REQUEST,
				:counter_group => cgguid ,
				:time_interval => mk_time_interval(tmarr),
				:spaces => [space] ,
				:maxitems => 100 )

resp = get_response_zmq(zmq_endpt,req) 
puts "Found #{resp.hits.size} matches"

# Request 2 : key lookup to convert keys 
# into readable/resolved names
#
req2 = TrisulRP::Protocol.mk_request(
				TRP::Message::Command::KEY_LOOKUP_REQUEST,
				:counter_group => cgguid ,
				:keys => resp.hits)

resp2 = get_response_zmq(zmq_endpt,req2) 
	
resp2.key_details.each do | kdetail  |
	puts "Hit Key  #{kdetail.key}  #{kdetail.label} "
end 

