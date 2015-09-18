# Trisul Remote Protocol TRP Demo script
#
# Counter Group Info
#
# Prints information about all supported couner  groups on a trisul instance
#
require 'trisulrp'


USAGE = "Usage:   cginfo.rb   ZMQ_ENDPOINT CGGUID\n" \
        "Example: 1) ruby cginfo.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}\n"\
        "         2) ruby cginfoall.rb tcp://localhost:5555 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}" 

# usage 
unless ARGV.size==2
  abort USAGE
end

zmq_endpt   = ARGV[0]
target_guid = ARGV[1]
req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
                                    :counter_group => target_guid )

# print a single counter group info
get_response_zmq(zmq_endpt,req) do |resp|
  resp.group_details.each do |group_detail|
     p "Start Time = #{Time.at(group_detail.time_interval.from.tv_sec)}"
     p "End time = #{Time.at(group_detail.time_interval.to.tv_sec)}"
     p "Bucket Size = #{group_detail.bucket_size}"
     p "Name = " + group_detail.name
     p "GUID = " + group_detail.guid
  end
end
