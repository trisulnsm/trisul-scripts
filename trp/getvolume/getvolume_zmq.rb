#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Same as getvolume.rb but via ZMQ interface 
#
# Example 
#  ruby getvolume_zmq.rb tcp://localhost:5555 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050 
#
#
require 'trisulrp'

USAGE = \
    "Usage:   getvolume.rb  ZMQ_ENDPT CGGUID CGKEY \n" \
	"Example: ruby getvolume.rb tcp://localhost:5555  {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050" 

# usage 
raise  USAGE  unless ARGV.size==3

zmq_endpt 	 = ARGV[0]
target_guid  = ARGV[1] 
target_key   = ARGV[2]


# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 

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
                                    :time_interval => mk_time_interval(tmarr) )

# print volume for each meter
get_response_zmq(zmq_endpt,req) do |resp|
  volume = resp.stats.meters.each do | meter|
    vol_bytes = meter.values[0].val * target_bucket_size 
      print "Volume of Meter #{meter.meter} = #{vol_bytes } bytes  \n"
  end 
end

