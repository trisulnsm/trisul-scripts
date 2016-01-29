
#!/usr/local/bin/ruby
#
# SAME AS query-flow.rb but uses ZMQ transport 
# Example 
#  ruby query-flow_zmq zmq:endpoint <opts> 
#
require 'trisulrp'

USAGE = "Usage:   query-flow_zmq.rb  ZMQ_ENDPOINT key=value \n" \
        "Example: 1) ruby query-flow_zmq.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 source_ip=C0.A8.01.01\n"\
        "         2) ruby query-flow_zmq.rb tcp://localhost:5555 source_ip=C0.A8.01.01" 

# usage 
unless ARGV.length>=2
  abort USAGE
end


#ZMQ connection end point
zmq_endpt= ARGV.shift


# process arguments 
qhash = ARGV.inject({}) do |acc,i|
	qparts = i.split("=")
	acc.store( qparts[0].to_sym, qparts[1])
	acc
end

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::QUERY_SESSIONS_REQUEST,
				qhash.merge( { 
					:time_interval => mk_time_interval(tmarr),
					:resolve_keys => true
				})
				)


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

