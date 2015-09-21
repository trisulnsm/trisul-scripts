#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Print all active keys in given range and time interval 
#
#
require 'trisulrp'

# Check arguments
#active_keys.rb - keys active in a range. Use to print all hosts seen in subnet etc

USAGE = "Usage : ruby active_keys.rb ZMQ_ENDPOINT CGGUID KFROM KTO \n"\
        "Example : 1) ruby active_keys.rb tcp://localhost:5555 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0000 p-FFFF\n"\
        "          2) ruby active_keys.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}  p-0000 p-FFFF"


unless ARGV.size == 4
  abort USAGE
end

#Get ZeroMQ end point
zmq_endpt = ARGV[0]

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 3*86400

# arguments
cgguid = ARGV[1]
from_key = ARGV[2]
to_key = ARGV[3]


# space message 
space = TRP::KeySpaceRequest::KeySpace.new( :from => from_key , :to => to_key)

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::KEYSPACE_REQUEST,
        :counter_group => cgguid ,
        :time_interval => mk_time_interval(tmarr),
        :spaces => [space] ,
        :maxitems => 5 )


# print hits 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.hits.size} matches"
  resp.hits.each do | res  |
    puts "Hit Key  #{res} "
  end 
end

