#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Runs a set of FQDNs past all names known by Trisul 
#
# Example 
#  ruby search_fqdn5.rb 192.168.1.12 12001 fqdn-list.txt 
#
require 'trisulrp'

USAGE = "Usage:   search_fqdn.rb  TRP-SERVER TRP-PORT NAMES-FILE\n" \
        "Example: ruby search_fqdn.rb 192.168.1.12 12001 dns_list.txt " 

# usage 
raise  USAGE  unless ARGV.size==3

# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get all time ..
tmarr  = TrisulRP::Protocol.get_available_time(conn)

# send resource group request 
# we want resource group RG_DNS identified by GUID {D1E2..} see docs 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_GROUP_REQUEST,
				:resource_group => RG_DNS,
				:time_interval => mk_time_interval(tmarr),
				:uri_list => File.read(ARGV[2])
							.split("\n")
							.collect {|a| a.strip} )

# print resource ids, 
get_response(conn,req) do |resp|
	puts "Found #{resp.resources.size} matches"
	resp.resources.each do | res  |
		puts "Resource #{res.slice_id}:#{res.resource_id} "
	end 
end

