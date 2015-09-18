#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Elephant Flows - flows that transfer huge amounts of data
# - These flows are tracked by Trisul as Tracker #0
#
#
#
require 'trisulrp'

# Check arguments

USAGE = "Usage   : ftracker.rb ZMQ_ENDPOINT trackerid\n"\
        "Example : 1) ruby ftracker.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 1\n"\
        "          2) ruby ftracker.rb tcp://localhost:5555 1"

#usage
unless ARGV.size ==2 
  abort USAGE
end

#zmq end point
zmq_endpt = ARGV[0]

# get all time..then for this demo script  crop to latest 1 day, 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1]-86400

# arguments
trackerid = ARGV[1]

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::SESSION_TRACKER_REQUEST,
                  :tracker_id  => trackerid.to_i,
                  :time_interval => mk_time_interval(tmarr))


# print matching flows using the print_session_details helper  
get_response_zmq(zmq_endpt,req) do |resp|
  print_session_details_header()
  resp.sessions.each do |s|
    print_session_details(s)
  end
end

