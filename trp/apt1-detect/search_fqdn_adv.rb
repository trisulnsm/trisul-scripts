#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Next level for search_fqdn.rb 
#
# 1. Runs a set of FQDNs past all names known by Trisul 
# 2. Prints not just the ResourceID but actual contents of resource 
#
#

require 'trisulrp'

USAGE = "Usage   : search_fqdn_adv.rb  ZMQ_CONNECTION NAMES-FILE\n"\
        "Examples: 1) ruby search_fqdn_adv.rb tcp://localhost:5555 dns_list.txt \n "\
        "         2) ruby search_fqdn_adv.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 dns_list.txt"


# usage 
unless ARGV.size==2
  abort USAGE
end

# get a zemomq connection point
zmq_endpt    = ARGV[0]

# get all time ..
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)

# send resource group request 
# we want resource group RG_DNS identified by GUID {D1E2..} see docs 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::RESOURCE_GROUP_REQUEST,
                                      :resource_group => RG_DNS,
                                      :time_interval => mk_time_interval(tmarr),
                                      :uri_list => File.read(ARGV[1])
                                                     .split("\n")
                                                     .collect {|a| a.strip} )

# get  resource ids in response 
rid_resp = get_response_zmq(zmq_endpt,req) 

# send resource item request to get details of each resource id 
#
detailed_req  = TrisulRP::Protocol.mk_request(TRP::Message::Command::RESOURCE_ITEM_REQUEST,
                                              :resource_group => RG_DNS,
                                              :resource_ids => rid_resp.resources ) 

detailed_resp = get_response_zmq(zmq_endpt,detailed_req) 
detailed_resp.items.each do |item|
    puts "#{item.resource_id.slice_id}:#{item.resource_id.resource_id} " \
         "#{Time.at(item.time.tv_sec)} #{item.uri}"
end

