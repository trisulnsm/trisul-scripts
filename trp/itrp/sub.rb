# Trisul Remote Protocol TRP Demo script
#
# Test the public sub interface 
#
# ruby sub.rb tcp://192.168.1.8:5555  
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

  Usage   : pubsub.rb  trisul-zmq-endpt-sub  [addcg delcg addids delids addtop deltop addflow ] 
  Example : pubsub.rb  tcp://192.168.1.8:5555 addcg 

} unless ARGV.length==2


# parameters 
#
zmq_endpt_sub   = ARGV.shift
cmd   = ARGV.shift

zmq_ctx = ZMQ::Context.new

# add a subscription to Counter Item 
#
s1 = zmq_ctx.socket(ZMQ::PUSH)
s1.connect(zmq_endpt_sub)

if cmd=="addcg" 
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
					 :guid => TrisulRP::Guids::CG_HOST,
					 :key => "C0.A8.02.08")
elsif cmd=="delcg"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
					 :guid => TrisulRP::Guids::CG_HOST,
					 :key => "C0.A8.02.08")
elsif cmd=="addids"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_ALERT,
					 :guid => TrisulRP::Guids::AG_IDS)
elsif cmd=="delids"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_ALERT,
					 :guid => TrisulRP::Guids::AG_IDS)
elsif cmd=="addtop"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_TOPPER,
					 :guid => TrisulRP::Guids::CG_HOST,
					 :meterid  => 0)
elsif cmd=="deltop"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_TOPPER,
					 :guid => TrisulRP::Guids::CG_HOST )
elsif cmd=="addflow"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_FLOW,
					 :guid => TrisulRP::Guids::SG_TCP,
					 :key  => 'p-0050' )
end

s1.send_string(req.serialize_to_string)


