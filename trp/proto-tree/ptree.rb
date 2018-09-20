# Protocol Tree 
#  script prints out a protocol tree, 
#  Used along with the Protocol Tree LUA plugin 
#  ruby ptree.rb tcp://192.168.2.99:13456
#
require 'trisulrp'
USAGE = " ptree.rb - prints a nice protocol tree \n"\
        "            ruby toppers_zmq.rb tcp://localhost:5555 \n"

unless ARGV.length==1
  abort USAGE
end


zmq_endpt   = ARGV.shift

# toppers  - bytes 
req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_REQUEST,
	 :counter_group => ",
	 :meter => target_meter.to_i,
	 :time_interval =>  mk_time_interval([Time.at(0),Time.at(9999999999)]))

TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) do |resp|
	  print "Counter Group = #{resp.counter_group}\n"
	  print "Meter = #{resp.meter}\n"
	  resp.keys.each do |key|
		  total_bytes = key.metric * 300
		  print "Key = #{key.key} Label = #{key.label}  Metric= #{total_bytes}\n"
	  end
end


# toppers - packets 



