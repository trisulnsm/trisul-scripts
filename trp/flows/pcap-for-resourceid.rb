#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
#
#
# Usage  
#  ruby pcap-for-resourceid  ZMQ_ENDPOINT sliceid:resid 
#
require 'trisulrp'

USAGE = "Usage:   pcap-for-resourceid.rb  ZMQ_ENDPOINT sliceid:flowid \n" \
        "Example: 1) ruby pcap-for-resourceid.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 2:23232\n"\
        "         2) ruby pcap-for-resourceid.rb tcp://localhost:5555 2:1111,1:23232" 

# usage 
unless ARGV.size==2
  abort USAGE
end


#ZMQ connection end point
zmq_endpt= ARGV.shift

by =  TRP::FilteredDatagramRequest::ByResource.new( 
  :resource_group => "{4EF9DEB9-4332-4867-A667-6A30C5900E9E}",
  :resource_ids  => ARGV.shift.split(',').collect do | sid |
          sessid = sid.split(':').map(&:to_i) 
          TRP::ResourceID.new({ :slice_id => sessid[0], :resource_id  => sessid[1]})  
        end
)


req = TrisulRP::Protocol.mk_request(
  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
  :resource  => by  
  )

get_response_zmq(zmq_endpt,req) do |fdr|
    File.open("#{fdr.sha1}.pcap","wb") do |f|
    f.write(fdr.contents)
    end
    print "Saved to #{fdr.sha1}.pcap\n"
end

