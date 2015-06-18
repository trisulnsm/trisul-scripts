# Trisul Remote Protocol TRP Demo script
#
# Test the public sub interface 
#
# ruby pubsub.rb tcp://192.168.1.8:5555  
#
#
require 'trisulrp'
require 'readline'
require 'rb-readline'
require 'terminal-table'
require 'matrix'

# Check arguments
raise %q{


  pubsub.rb - test the pubsub interface 

  Usage   : pubsub.rb  trisul-zmq-endpt-sub trisul-zmq-endpt-pub 
  Example : pubsub.rb  tcp://192.168.1.8:5555 tcp://192.168.1.8:5556 

} unless ARGV.length==2


# parameters 
#
zmq_endpt_sub   = ARGV.shift
zmq_endpt_pub   = ARGV.shift

zmq_ctx = ZMQ::Context.new

# add a subscription to Counter Item 
#
s1 = zmq_ctx.socket(ZMQ::PUSH)
s1.connect(zmq_endpt_sub)
req =mk_request(TRP::Message::Command::STAB_SUBSCRIBE,
				 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
				 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
				 :guid => TrisulRP::Guids::CG_HOST,
				 :key => "C0.A8.02.08")
s1.send_string(req.serialize_to_string)



# now start priting whatever you get on PUB channel 
#
s2 = zmq_ctx.socket(ZMQ::SUB)
s2.connect(zmq_endpt_pub)
s2.setsockopt(ZMQ::SUBSCRIBE,"")


# Process tasks forever
while true
	
	pubmsg = ""
	s2.recv_string(pubmsg)

	p pubmsg

end


