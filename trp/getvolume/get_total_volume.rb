#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Same as getvolume.rb but via ZMQ interface 
#
# Example 
#  ruby get_total_volume.rb tcp://localhost:5555 
#
#
require 'trisulrp'
require '../helpers/model_utils.rb'

USAGE = "Usage:   getvolume.rb  ZMQ_ENDPT CGGUID CGKEY \n" \
        "Example: 1) ruby get_total_volume.rb tcp://localhost:5555 \n"\
        "         2) ruby get_total_volume.rb ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0"

# usage 
unless ARGV.size==1
  abort USAGE
end

zmq_endpt    = ARGV[0]
target_guid  = "{393B5EBC-AB41-4387-8F31-8077DB917336}"
target_key   = "TOTALBW"


# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 
bucket_size = 60

# find out the bucket size in seconds 
req = mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
                                       :counter_group => target_guid )
resp = TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) 
target_bucket_size = resp.group_details[0].bucket_size 

# send request for http ( cg=APPS, key=p-0050) 
# notice use of volumes_only => 1 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
                                    :counter_group=> target_guid ,
                                    :key=> target_key ,
                                    :volumes_only=>1,
                                    :time_interval => mk_time_interval(tmarr) )

# print volume for each meter
get_response_zmq(zmq_endpt,req) do |resp|
  p "Total Volume : #{ModelUtils::fmt_volume(resp[:totals].values.first*bucket_size,'B')}"
end

