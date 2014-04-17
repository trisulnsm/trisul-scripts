#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Next level for search_fqdn.rb 
#
# 1. Runs a set of FQDNs past all names known by Trisul 
# 2. Prints not just the ResourceID but actual contents of resource 
#
#
# Example 
#  ruby search_fqdn_adv.rb 192.168.1.12 12001 fqdn-list.txt 
#
require 'trisulrp'

USAGE = "Usage:   search_fqdn_adv.rb  TRP-SERVER TRP-PORT NAMES-FILE\n" \
        "Example: ruby search_fqdn_adv.rb 192.168.1.12 12001 dns_list.txt " 

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

# get  resource ids in response 
rid_resp = get_response(conn,req) 

# send resource item request to get details of each resource id 
#
detailed_req  = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_ITEM_REQUEST,
				:resource_group => RG_DNS,
				:resource_ids => rid_resp.resources ) 

detailed_resp = get_response(conn,detailed_req) 
detailed_resp.items.each do |item|
		puts "#{item.resource_id.slice_id}:#{item.resource_id.resource_id} " \
		     "#{Time.at(item.time.tv_sec)} #{item.uri}"
end

