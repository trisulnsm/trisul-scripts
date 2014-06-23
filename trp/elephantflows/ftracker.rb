#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Elephant Flows - flows that transfer huge amounts of data
# - These flows are tracked by Trisul as Tracker #0
#
#
#
require 'trisulrp'

# Check arguments
raise %q{


  ftracker.rb - Print flow tracker (0=volume) for past 24 hours

  Usage 
  ftracker.rb  trisul-ip trp-port tracker-id 

  Example
  ruby ftracker.rb 192.168.1.22 12001 1

} unless ARGV.length==3


# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")
#conn  = connect_nonsecure(ARGV[0],ARGV[1])

# get all time..then for this demo script  crop to latest 1 day, 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1]-86400

# arguments
trackerid = ARGV[2]

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::SESSION_TRACKER_REQUEST,
				:tracker_id  => trackerid.to_i,
				:time_interval => mk_time_interval(tmarr))


# print matching flows using the print_session_details helper  
get_response(conn,req) do |resp|
	print_session_details_header()
	resp.sessions.each do |s|
		print_session_details(s)
	end
end

