#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search for matches in key space (IP Ranges in this case)
#
# Example 
#  ruby search_keyspace.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 keyspaces.txt 
#
#  keyspaces.txt is in the format
#  19.88.100.0-19.88.103.0 
#  or just (for exact match) 
#  19.88.100.121 
#
require 'trisulrp'

USAGE = "Usage   : search_keyspace.rb  ZMQ_ENDPOINT NAMES-FILE\n"\
        "Examples: 1) ruby search_keyspace.rb tcp://localhost:5555 ip-ranges.txt \n "\
        "         2) ruby search_keyspace.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 ip-ranges.txt"


# usage 
unless ARGV.size==2
  abort USAGE
end

# zmq end point
zmq_endpt  = ARGV[0]

# get all time..then for this demo script  crop to latest 1 day, 
# in production loop for each day ..
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1]-86400
# read in keyspaces 
spaces=File.readlines(ARGV[1]).collect  do |l|
  p = l.chomp.split("-")
  if p.size==2
    TRP::KeySpaceRequest::KeySpace.new(
      :from => make_key(p[0]), :to => make_key(p[1]))
  elsif p.size==1
    TRP::KeySpaceRequest::KeySpace.new(
      :from => make_key(p[0]), :to => make_key(p[0]))
  end
end


# send keyspace request 
# we want keys in CG_HOSTS 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::KEYSPACE_REQUEST,
                                      :counter_group => CG_HOST,
                                      :time_interval => mk_time_interval(tmarr),
                                      :spaces => spaces)


# print hits 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.hits.size} matches"
  resp.hits.each do | res  |
    puts "Hit Key  #{res} "
  end 
end

