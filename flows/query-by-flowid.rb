
#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Query by flow id , every flow in Trisul has a unique id 
# of the form slice:session. Eg 1:999 
#
# Example 
#  ruby query-by-flowid TRPHOST TRPPORT  id
#
require 'trisulrp'

# Check arguments
raise %q{


  query-by-flowid.rb - Query flow by id

  Usage 
  query-by-flowid.rb  trisul-ip trp-port flowid

  Example
  ruby query-by-flowid.rb 192.168.1.22 12001  1:801 

} unless ARGV.length==3


# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# arguments convert to a SessionID object 
flowid  = ARGV[2].split(':').collect{|a|a.to_i}
sessid  = TRP::SessionID.new( {:slice_id=>flowid[0],
                               :session_id=>flowid[1]} )


# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::SESSION_ITEM_REQUEST,
				:session_ids  => [sessid] )


# print matching flows using the print_session_details helper  
get_response(conn,req) do |resp|
	 resp.items.each do |item|
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

