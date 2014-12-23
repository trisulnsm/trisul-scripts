#!/usr/local/bin/ruby
#
# query pdp via zmq interface 
#
require 'trisulrp'

# Check arguments
raise %q{


  query-pdp.rb - Query pdp by any params 

  Usage 
  query-pdp.rb  trisul-ip trp-port <opts>

  <opts x=y>
  x=imsi,rai,.. any of the 9 keys` 


  Example
  ruby query-pdp.rb 192.168.1.22 12001  ipa=C0.A8.01.01 

} unless ARGV.length>=2


# open a connection to Trisul server from command line args
conn  = ARGV.shift

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
                TRP::Message::Command::QUERY_PDP_REQUEST,
				qhash.merge( { 
					:time_interval => mk_time_interval(tmarr),
					:maxitems => 10
				})
				)


# print matching flows using the print_session_details helper  
get_response_zmq(conn,req) do |resp|
	 resp.sessions.each do |item|
		print "#{item.session_id.slice_id}:#{item.session_id.session_id} "
		print "#{Time.at(item.time_interval.from.tv_sec)} "
		print "#{item.time_interval.to.tv_sec-item.time_interval.from.tv_sec} ".rjust(8)
		print "#{item.msisdn}".ljust(14)
		print "#{item.mccmnc}".ljust(10)
		print "#{item.ipa}".ljust(14)
		print "#{item.imei}".ljust(18)
		print "#{item.imsi}".ljust(18)
		print "#{item.apn}".ljust(11)
		print "#{item.rai}".ljust(11)
		print "#{item.rat}".ljust(11)
		print "#{item.uli}".ljust(14)
		print "[#{item.cause}]".ljust(4)
		print "#{item.trace}"
		print "\n"
	 end
end

