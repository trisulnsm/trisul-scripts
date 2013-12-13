#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Print all active keys in given range and time interval 
#
# This is an advanced version of active_keys.rb 
# 	1. accepts  human readable ranges ( 192.168.0.0 instead of Trisul format C0.A8.00.00)
# 	2. interprets and prints the keys 
#
#
require 'trisulrp'

# Check arguments
raise %q{


  active_keys2.rb - keys active in a range. Use to print all hosts seen in subnet etc

  Usage 
  active_keys2.rb  trisul-ip trp-port cgguid kfrom kto 

  Example
  ruby active_keys2.rb 192.168.1.45 12001 host 192.168.0.0 192.169.0.0 

  The example retrieves all ports seen in last 24 hours 

} unless ARGV.length==5


# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get all time..then for this demo script  crop to latest 1 day, 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1]-86400

# arguments
cgguid = ARGV[2]

# we use the make_key helper function to convert human to key format 
from_key = make_key(ARGV[3])
to_key = make_key(ARGV[4])


# space message 
space = TRP::KeySpaceRequest::KeySpace.new( :from => from_key , :to => to_key)


# Request 1 : for active keys 
# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::KEYSPACE_REQUEST,
				:counter_group => cgguid ,
				:time_interval => mk_time_interval(tmarr),
				:spaces => [space] ,
				:maxitems => 100 )

resp = get_response(conn,req) 
puts "Found #{resp.hits.size} matches"

# Request 2 : key lookup to convert keys 
# into readable/resolved names
#
req2 = TrisulRP::Protocol.mk_request(
				TRP::Message::Command::KEY_LOOKUP_REQUEST,
				:counter_group => cgguid ,
				:keys => resp.hits)

resp2 = get_response(conn,req2) 
	
resp2.key_details.each do | kdetail  |
	puts "Hit Key  #{kdetail.key}  #{kdetail.label} "
end 

