#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# ** Same as fracker.rb ** but uses zmq transport 
#
#
require 'trisulrp'

# Check arguments
raise %q{


  ftracker-zmq.rb - Print flow tracker (0=volume) for past 24 hours

  Usage 
  ftracker-zmq.rb  zmq-endpoint tracker-id 

  Example
  ruby ftracker-zmq.rb tcp://localhost:89237 1 

} unless ARGV.length==2


endpt = ARGV[0]

# get all time..then for this demo script  crop to latest 1 day, 
tmarr  = TrisulRP::Protocol.get_available_time(endpt)
tmarr[0] = tmarr[1]-86400

# arguments
trackerid = ARGV[1]

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::SESSION_TRACKER_REQUEST,
				:tracker_id  => trackerid.to_i,
				:time_interval => mk_time_interval(tmarr))


# print matching flows using the print_session_details helper  
get_response_zmq(endpt,req) do |resp|
	print_session_details_header()
	resp.sessions.each do |s|
		print_session_details(s)
	end
end

