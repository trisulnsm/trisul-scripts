#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search all flows (incl HTTP) for a text pattern
#
# Example 
#  ruby search_text.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 \"hello this is a test \"

#
#
require 'trisulrp'

USAGE = "Usage   : search_text.rb  ZMQ_CONNECTION \"hello this is a test\"\n"\
        "Examples: 1) ruby search_text.rb tcp://localhost:5555 \"hello this is a test\"\n "\
        "         2) ruby search_text.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 \"hello this is a test\""

# usage 
unless ARGV.size==2
  abort USAGE
end

#  zmq end point
zmq_endpt  = ARGV[0]

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 



# send grep request  (GrepRequest)
# read md5s from file given as input 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
                                      :time_interval => mk_time_interval(tmarr),
                                      :pattern => ARGV[2]  )

# print matching flows if any 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.sessions.size} matches"
  resp.sessions.each_with_index  do | sess, idx  |
    puts "Flow #{sess.slice_id}:#{sess.session_id} #{resp.hints[idx]} "
  end 
end

