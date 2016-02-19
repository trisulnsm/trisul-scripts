
#!/usr/local/bin/ruby
#
# SAME AS query-flow_zmq.rb but save flows to file
# Example 
#  ruby query-flow-file_zmq zmq:endpoint <opts> 
#
require 'trisulrp'

USAGE = "Usage:   query-flow-file_zmq.rb  ZMQ_ENDPOINT key=value \n" \
        "Example: 1) ruby query-flow-file_zmq.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 source_ip=C0.A8.01.01\n"\
        "         2) ruby query-flow-file_zmq.rb tcp://localhost:5555 source_ip=C0.A8.01.01" 

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
outputfile=File.join("/tmp","Flows_#{rand(1000000000)}.csv")
req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::QUERY_SESSIONS_REQUEST,
        qhash.merge( { 
          :time_interval => mk_time_interval(tmarr),
          :resolve_keys => true,
          :outputpath=>outputfile
        })
      )


# print matching flows using the print_session_details helper  
get_response_zmq(zmq_endpt,req) do |resp|
    p "Output file : #{outputfile}"
end

