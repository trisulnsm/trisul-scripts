#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Get last 24-hours volume of traffic for any item 
#
# You need to know the following
#  - Counter Group ID of the counter 
#  - Meter ID within the Counter Group
#  - Key identifying the entity 
#
# Example 
#  ruby getvolume.rb 192.168.1.12 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050 0
#
# Will print out hourly stats of HTTP (p-0050) within Apps (GUID C-51..) and meter Total(0)
#
require 'trisulrp'

USAGE = "Usage:   getvolume.rb  TRP-SERVER TRP-PORT CGGUID CGKEY \n" \
        "Example: ruby getvolume.rb 192.168.1.12 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050" 

# usage 
raise  USAGE  unless ARGV.size==4

# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

target_guid  = ARGV[2] 
target_key   = ARGV[3]


# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600 

# find out the bucket size in seconds 
req = mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
                                       :counter_group => target_guid )
resp = TrisulRP::Protocol.get_response(conn,req) 
target_bucket_size = resp.group_details[0].bucket_size 

# send request for http ( cg=APPS, key=p-0050) 
# notice use of volumes_only => 1 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
                                    :counter_group=> target_guid ,
                                    :key=> target_key ,
                                    :time_interval => mk_time_interval(tmarr),
									:volumes_only => 1 )

# print volume for each meter
get_response(conn,req) do |resp|
	volume = resp.stats.meters.each do | meter|
		vol_bytes = meter.values[0].val * target_bucket_size 
	  	print "Volume of Meter #{meter.meter} = #{vol_bytes } bytes  \n"
	end 
end

