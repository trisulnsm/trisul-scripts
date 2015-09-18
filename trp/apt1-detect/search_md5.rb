#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search *ALL* HTTP objects for matching MD5 
# in last 24 hours. Reconstructs TCP/Decompresses/Dechunks
# while hashing. 
#
# Example 
#  ruby search_md5.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 md5s.txt 
#
# Will print out matching flows, you can extract the packets from each of
# those flows using FilteredDatagramRequest(..) 
#
require 'trisulrp'

USAGE = "Usage   : search_md5.rb  ZMQ_CONNECTION NAMES-FILE\n"\
        "Examples: 1) ruby search_md5.rb tcp://localhost:5555 md5s.txt \n "\
        "         2) ruby search_md5.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 md5s.txt"


# usage 
unless ARGV.size==2
  abort USAGE
end


# zmq end point
zmq_endpt  = ARGV[0]

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 


# send grep request  (GrepRequest)
# read md5s from file given as input 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
                                      :time_interval => mk_time_interval(tmarr),
                                       :md5list => File.read(ARGV[1])
                                                   .split("\n")
                                                   .collect {|a| a.strip} )

# print matching flows if any 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.sessions.size} matches"
  resp.sessions.each_with_index  do | sess, idx  |
    puts "Flow #{sess.slice_id}:#{sess.session_id} #{resp.hints[idx]} "
  end 
end

