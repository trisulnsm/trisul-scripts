# Trisul Remote Protocol TRP Demo script
#
# Topper Trend 
#	Traffic trends for topper items 
#	
#  ruby topper_trend.rb zmq-endpt {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} 1
#
require 'trisulrp'

# Check arguments
raise %q{
  topper-trend.rb - Retrieve toppers for any counter and stat for last 1 day 

  Usage   : topper-trend.rb  zmq-entpt cgguid meter-id
  Example : ruby topper-trend.rb tcp://localhost:5555 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} 0

  The example retrieves toppers for Apps (guid {C51..}) and meter 0 (total bytes)

} unless ARGV.length==3


zendpt = ARGV.shift 

# parameters 
target_guid  = ARGV.shift
target_meter = ARGV.shift

# last 24 hours
tmarr= TrisulRP::Protocol.get_available_time(zendpt)
tmarr[0] = tmarr[1] - 24*3600 

# get keys
req =TrisulRP::Protocol.mk_request(
	TRP::Message::Command::TOPPER_TREND_REQUEST,
	 :counter_group => target_guid,
	 :meter => target_meter.to_i,
	 :time_interval =>  mk_time_interval(tmarr))

TrisulRP::Protocol.get_response_zmq(zendpt,req) do |resp|
	  print "Counter Group = #{resp.counter_group}\n"
	  print "Meter = #{resp.meter}\n"
	  print "Numkeys = #{resp.keytrends.size}\n"
	  resp.keytrends.each do |kt|
	  	print "key = #{kt.key}\n"
		m = kt.meters[0]
	  	print "meter = #{m.meter}\n"
		m.values.each do |v|
			print "ts = #{v.ts.tv_sec}=#{v.val}\n"
		end

		
	  end
end
