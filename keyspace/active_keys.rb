#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Print all active keys in given range and time interval 
#
# Example 
#  ruby search_keyspace.rb 192.168.1.12 12001 cgguid from-key-pattern to-key-pattern 
#
#
require 'trisulrp'

# Check arguments
raise %q{


  active_keys.rb - keys active in a range. Use to print all hosts seen in subnet etc

  Usage 
  active_keys.rb  trisul-ip trp-port cgguid kfrom kto 

  Example
  ruby active_keys.rb 192.168.1.45 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0000 p-FFFF

  The example retrieves all ports seen in last 24 hours 

} unless ARGV.length==5


# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get all time..then for this demo script  crop to latest 1 day, 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1]-86400

# arguments
cgguid = ARGV[2]
from_key = ARGV[3]
to_key = ARGV[4]


# space message 
space = TRP::KeySpaceRequest::KeySpace.new( :from => from_key , :to => to_key)

# send keyspace request 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::KEYSPACE_REQUEST,
				:counter_group => cgguid ,
				:time_interval => mk_time_interval(tmarr),
				:spaces => [space] ,
				:maxitems => 100 )


# print hits 
get_response(conn,req) do |resp|
	puts "Found #{resp.hits.size} matches"
	resp.hits.each do | res  |
		puts "Hit Key  #{res} "
	end 
end

