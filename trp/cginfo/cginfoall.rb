# Trisul Remote Protocol TRP Demo script
#
# Counter Group Info 2 
#
#
# Prints info about all counter groups 
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'


require 'trisulrp'


USAGE = "Usage:   cginfoall.rb   ZMQ_ENDPOINT\n" \
        "Example: 1) ruby cginfoall.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0\n"\
        "         2) ruby cginfoall.rb tcp://localhost:5555"

# usage 
unless ARGV.size==1
  abort USAGE
end

#zmq end point
zmq_endpt = ARGV[0]

# print info about all counter groups, 
# note that we have not specified the counter_group guid in the request
# So all the counter groups are retrieved.
req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)

get_response_zmq(zmq_endpt,req) do |resp|
  resp.group_details.each do |group_detail|
   print  group_detail.name.ljust(25)
   print  group_detail.guid
   print " #{Time.at(group_detail.time_interval.from.tv_sec)}  "
   print " #{Time.at(group_detail.time_interval.to.tv_sec)}  "
   print " #{group_detail.bucket_size}  "
   print "\n"
  end
end
