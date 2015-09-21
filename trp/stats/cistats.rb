# Trisul Remote Protocol TRP Demo script
#
# Counter item stats
#
# All stats for all time for a particular counter item (press Ctrl+C to stop )
# 
#  ruby cistats.rb tcp://192.168.1.8:5555  {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050
#  ruby cistats.rb tcp://192.168.1.8:5555  {393B5EBC-AB41-4387-8F31-8077DB917336} TOTALBW
#
#
require 'trisulrp'

# Check arguments
USAGE = "cistats.rb - Dump all stats \n"\
        "Usage   : cistats.rb  trisul-zmq-endpt cgguid key\n"\
        "Example : 1) ruby cistats.rb tcp://192.168.1.8:5555  {393B5EBC-AB41-4387-8F31-8077DB917336} TOTALBW\n"\
        "          2) ruby cistats.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0  {393B5EBC-AB41-4387-8F31-8077DB917336} TOTALBW"
unless ARGV.length==3
  abort USAGE
end

# parameters 
zmq_endpt   = ARGV.shift
target_guid  = ARGV.shift
target_key  = ARGV.shift

# get entire time window  
tmarr= TrisulRP::Protocol.get_available_time(zmq_endpt)

# toppers 
req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
	 :counter_group => target_guid,
	 :key => target_key,
	 :time_interval =>  mk_time_interval(tmarr) )

TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) do |resp|
	  print "Counter Group = #{resp.stats.counter_group}\n"
	  print "Key           = #{resp.stats.key}\n"
	  resp.stats.meters.each do |meter|
	  	print "----- Showing Meter #{meter.meter}\n"
	  	meter.values.each do |val|
		  print "#{Time.at(val.ts.tv_sec).to_s} = #{val.val}\n"
		end
	  end
end
