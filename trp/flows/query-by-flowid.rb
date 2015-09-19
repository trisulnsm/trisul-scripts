
#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Query by flow id , every flow in Trisul has a unique id 
# of the form slice:session. Eg 1:999 
#
# Example 
#  ruby query-by-flowid ZMQ_ENDPOINT  id
#
require 'trisulrp'

USAGE = "Usage:   query-by-flowid.rb  ZMQ_ENDPOINT sliceid:flowid \n" \
        "Example: 1) ruby query-by-flowid.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 2:23232\n"\
        "         2) ruby query-by-flowid.rb tcp://localhost:5555 2:1111" 

# usage 
unless ARGV.size==2
  abort USAGE
end


#ZMQ connection end point
zmq_endpt= ARGV[0]

# arguments convert to a SessionID object 
flowid  = ARGV[1].split(':').collect{|a|a.to_i}
sessid  = TRP::SessionID.new( {:slice_id=>flowid[0],
                               :session_id=>flowid[1]} )


# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::SESSION_ITEM_REQUEST,
        :session_ids  => [sessid] )


# print matching flows using the print_session_details helper  
get_response_zmq(zmq_endpt,req) do |resp|
   resp.sessions.each do |item|
    print "#{item.session_id.slice_id}:#{item.session_id.session_id} "
    print "#{Time.at(item.time_interval.from.tv_sec)} "
    print "#{item.time_interval.to.tv_sec-item.time_interval.from.tv_sec} ".rjust(8)
    print "#{item.protocol.key}".ljust(8)
    print "#{item.key1A.key}".ljust(28)
    print "#{item.key2A.key}".ljust(11)
    print "#{item.key1Z.key}".ljust(28)
    print "#{item.key2Z.key}".ljust(11)
    print "#{item.az_bytes}".rjust(10)
    print "#{item.za_bytes}".rjust(10)
    print "#{item.az_packets}".rjust(10)
    print "#{item.za_packets}".rjust(10)
    print "\n"
   end
end

