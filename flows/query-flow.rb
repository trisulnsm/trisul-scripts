
#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Any query ..  time window last 2 days 
#
# Example 
#  ruby query-flow TRPHOST TRPPORT <opts> 
#
require 'trisulrp'

# Check arguments
raise %q{


  query-flow.rb - Query flow by any params 

  Usage 
  query-flow.rb  trisul-ip trp-port <opts>

  <opts x=y>
  x=sourceip,destip,


  Example
  ruby query-flow.rb 192.168.1.22 12001 source_ip=C0.A8.01.01 

} unless ARGV.length>3


# open a connection to Trisul server from command line args
conn  = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")

# process arguments 
qhash = ARGV.inject({}) do |acc,i|
	qparts = i.split("=")
	acc.store( qparts[0].to_sym, qparts[1])
	acc
end

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::QUERY_SESSIONS_REQUEST,
				qhash.merge( { 
					:time_interval => mk_time_interval(tmarr),
					:resolve_keys => false
				})
				)


# print matching flows using the print_session_details helper  
get_response(conn,req) do |resp|
	 resp.sessions.each do |item|
		print "#{item.session_id.slice_id}:#{item.session_id.session_id} "
		print "#{Time.at(item.time_interval.from.tv_sec)} "
		print "#{item.time_interval.to.tv_sec-item.time_interval.from.tv_sec} ".rjust(8)
		print "#{item.protocol.key}".ljust(8)
		print "#{item.key1A.label}".ljust(28)
		print "#{item.key2A.label}".ljust(11)
		print "#{item.key1Z.label}".ljust(28)
		print "#{item.key2Z.label}".ljust(11)
		print "#{item.az_bytes}".rjust(10)
		print "#{item.za_bytes}".rjust(10)
		print "#{item.az_packets}".rjust(10)
		print "#{item.za_packets}".rjust(10)
		print "\n"
	 end
end

