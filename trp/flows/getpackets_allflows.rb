
#!/usr/local/bin/ruby
#
# SAME AS query-flow.rb but uses ZMQ transport 
# Example 
#  ruby query-flow_zmq zmq:endpoint <opts> 
#
require 'trisulrp'
require 'fileutils'

USAGE = "Usage:   query-flow_zmq.rb  DOMAIN_ZMQ_ENDPOINT key=value \n" \
        "Example: 1) ruby query-flow_zmq.rb ipc:///usr/local/var/lib/trisul/domain0/run/ctl_local_req  source_ip=C0.A8.01.01\n"\

# usage 
unless ARGV.length>=2
  abort USAGE
end


# ZMQ connection end point
zmq_domain_endpt= ARGV.shift

# Use 
req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::CONTEXT_CONFIG_REQUEST,
		{ :context_name  => 'default' })

resp = get_response_zmq(zmq_domain_endpt,req) 

zmq_trp_endpt = resp.endpoints_query.first 

p zmq_trp_endpt

# process arguments  into a sessions query 
qhash = ARGV.inject({}) do |acc,i|
  qparts = i.split("=")
  acc.store( qparts[0].to_sym, qparts[1])
  acc
end

# get 24 hrs latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_trp_endpt)
tmarr[0] = tmarr[1] - 24*3600

# send query session request
req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::QUERY_SESSIONS_REQUEST,
        qhash.merge( { 
          :time_interval => tmarr, 
          :resolve_keys => true,
          :maxcount=>10000
        })
      )


outputdir = "/tmp/savedpcap/"
if not Dir.exists?(outputdir)
	Dir.mkdir(outputdir)
end

get_response_zmq(zmq_trp_endpt,req) do |resp|
  resp.sessions.each do |item|
  	p item.session_id
  end
end



