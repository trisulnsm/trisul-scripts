#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search flows by any two combinations 
#
# Example 
#  ruby flows_2.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 [IP|PORT] [IP|PORT]
#
# Will print out matching flows, you can extract the packets from each of
# those flows using FilteredDatagramRequest(..) 
#
require 'trisulrp'

USAGE = "Usage:   flows_2.rb  ZMQ_ENDPOINT [IP|PORT] [IP|PORT] \n" \
        "Example: 1) ruby flows_2.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 youtube.com 192.168.1.2\n"\
        "         2) ruby flows_2.rb tcp://localhost:5555 youtube.com 192.168.1.2" 

# usage 
unless ARGV.size==3
  abort USAGE
end


#ZMQ connection end point
zmq_endpt= ARGV[0]

# get 48 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 48*3600 

# make keys (convert names/human readable into trisul)
# if no conversion possible then try interchanging host/port
k1 = mk_trisul_key(zmq_endpt,CG_HOST,ARGV[1])
if k1==ARGV[1]
  k1 = mk_trisul_key(zmq_endpt,CG_APP,ARGV[1])
end

k2 = mk_trisul_key(zmq_endpt,CG_HOST,ARGV[2])
if k2==ARGV[2]
  k2 = mk_trisul_key(zmq_endpt,CG_APP,ARGV[2])
end 


# send  KEY_SESSION_ACTIVITY_REQUEST 
# read md5s from file given as input 
req = TrisulRP::Protocol.mk_request(
               TRP::Message::Command::KEY_SESS_ACTIVITY_REQUEST,
                :time_interval => mk_time_interval(tmarr),
                  :key => k1,
                  :key2 => k2)

# print matching flows if any 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.sessions.size} matches"
  resp.sessions.each_with_index  do | sess, idx  |
    puts "Flow #{sess.slice_id}:#{sess.session_id}"

    # once you have the sess_id you can pull out packets etc.. 
    # see other samples 
  end 
end

