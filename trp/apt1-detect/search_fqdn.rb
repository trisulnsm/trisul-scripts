#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Runs a set of FQDNs past all names known by Trisul 
#
# Example 
#  ruby search_fqdn.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 dns_list.txt 
#
require 'trisulrp'

USAGE = "Usage   : search_fqdn.rb  ZMQ_ENDPOINT NAMES-FILE\n"\
        "Examples: 1) ruby search_fqdn.rb tcp://localhost:5555 dns_list.txt \n "\
        "         2) ruby search_fqdn.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 dns_list.txt"


# usage 
unless ARGV.size==2
  abort USAGE
end


# zmq connection point
zmq_endpt    = ARGV[0]
# get all time ..
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)

# send resource group request 
# we want resource group RG_DNS identified by GUID {D1E2..} see docs 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_GROUP_REQUEST,
                  :resource_group => RG_DNS,
                  :time_interval => mk_time_interval(tmarr),
                  :uri_list => File.read(ARGV[1])
                                .split("\n")
                                .collect {|a| a.strip} )

# print resource ids, 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.resources.size} matches"
  resp.resources.each do | res  |
    puts "Resource #{res.slice_id}:#{res.resource_id} "
  end 
end

