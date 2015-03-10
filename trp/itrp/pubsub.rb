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

  Usage   : pubsub.rb  trisul-zmq-endpt 
  Example : pubsub.rb  tcp://192.168.1.8:5555 

} unless ARGV.length==1


# parameters 
#
zmq_endpt   = ARGV.shift

zmq_ctx = ZMQ::Context.new(1)
socket = zmq_ctx.socket(ZMQ::XSUB)
socket.connect(zmq_endpt)


req =mk_request(TRP::Message::Command::STAB_SUBSCRIBE,
				 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
				 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
				 :guid => TrisulRP::Guids::CG_HOST,
				 :key => "C0.A8.02.08")

req_str = req.serialize_to_string
socket.send_string(req_str)

