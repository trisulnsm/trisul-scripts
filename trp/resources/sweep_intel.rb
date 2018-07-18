#
# sweep_intel :  Search the INTEL resource group for a match 
#
require 'trisulrp'

USAGE = "Usage:   sweep-intel.rb  ZMQ_ENDPT time-from time-to indicator \n" \

# usage 
abort USAGE unless ARGV.size==4

zmq_endpt = ARGV[0]
time_from_str = ARGV[1]
time_to_str  = ARGV[2]
pattern = ARGV[3]

time_interval=[ Time.parse(time_from_str), 
                Time.parse(time_to_str) ] 

p time_interval 

req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::QUERY_RESOURCES_REQUEST,
                :resource_group => "{EE1C9F46-0542-4A7E-4C6A-55E2C4689419}",
                :time_interval => time_interval,
                :regex_uri => pattern )

# print hits 
get_response_zmq(zmq_endpt,req) do |resp|
	resp.resources.each do |res|
		req2 = TrisulRP::Protocol.mk_request(
						TRP::Message::Command::QUERY_RESOURCES_REQUEST,
						:resource_group => "{EE1C9F46-0542-4A7E-4C6A-55E2C4689419}",
						:idlist => res.resource_id )
		get_response_zmq(zmq_endpt,req2) do |resp2|
			oneres = resp2.resources[0]
			print("#{oneres.probe_id}  #{oneres.resource_id}    #{oneres.userlabel}\n")
		end
	end
end 

