#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Given a flow id in slice:flowid format, get the pcap 
#
# Usage  
#  ruby pcapforflow ZMQ_ENDPOINT sliceid:flowid
#
require 'trisulrp'


USAGE = "Usage:   pcap-for-flowid.rb  ZMQ_ENDPOINT sliceid:flowid \n" \
        "Example: 1) ruby pcap-for-flowid.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 2:23232\n"\
        "         2) ruby pcap-for-flowid.rb tcp://localhost:5555 2:1111,1:23232" 

# usage 
unless ARGV.size==2
  abort USAGE
end


#ZMQ connection end point
zmq_endpt= ARGV.shift
bysession =   TRP::FilteredDatagramRequest::BySession.new( 
  :session_ids => ARGV.shift.split(',').collect do | sid |
          sessid = sid.split(':').map(&:to_i) 
          TRP::SessionID.new({ :slice_id => sessid[0], :session_id  => sessid[1]})  
        end
)


req = TrisulRP::Protocol.mk_request(
  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
  :session => bysession  
  )

get_response_zmq(zmq_endpt,req) do |fdr|
    File.open("#{fdr.sha1}.pcap","wb") do |f|
    f.write(fdr.contents)
    end
    print "Saved to #{fdr.sha1}.pcap\n"
end

