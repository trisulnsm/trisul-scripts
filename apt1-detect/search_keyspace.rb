#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search for matches in key space (IP Ranges in this case)
#
# Example 
#  ruby search_keyspace.rb 192.168.1.12 12001 keyspaces.txt 
#
#  keyspaces.txt is in the format
#  19.88.100.0-19.88.103.0 
#  or just (for exact match) 
#  19.88.100.121 
#
require 'trisulrp'

USAGE = "Usage:   search_keyspace.rb  TRP-SERVER TRP-PORT KEYS-FILE\n" \
        "Example: ruby search_keyspace.rb 192.168.1.12 12001 ip-ranges.txt " 

# usage 
raise  USAGE  unless ARGV.size==3

# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get all time..then for this demo script  crop to latest 1 day, 
# in production loop for each day ..
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1]-86400

# read in keyspaces 
spaces=File.readlines(ARGV[2]).collect  do |l|
	p = l.chomp.split("-")
	if p.size==2
		TRP::KeySpaceRequest::KeySpace.new(
			:from => make_key(p[0]), :to => make_key(p[1]))
	elsif p.size==1
		TRP::KeySpaceRequest::KeySpace.new(
			:from => make_key(p[0]), :to => make_key(p[0]))
	end
end


# send keyspace request 
# we want keys in CG_HOSTS 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::KEYSPACE_REQUEST,
				:counter_group => CG_HOST,
				:time_interval => mk_time_interval(tmarr),
				:spaces => spaces )


# print hits 
get_response(conn,req) do |resp|
	puts "Found #{resp.hits.size} matches"
	resp.hits.each do | res  |
		puts "Hit Key  #{res} "
	end 
end

