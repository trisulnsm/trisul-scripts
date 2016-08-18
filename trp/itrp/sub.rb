# Trisul Remote Protocol TRP Demo script
#
# Test the public sub interface 
#
# ruby sub.rb tcp://192.168.1.8:5555  
#
#
require 'trisulrp'

# Check arguments
raise %q{


  pubsub.rb - test the pubsub interface 

  Usage   : sub.rb  trisul-zmq-endpt-sub  [addcg delcg addids delids addtop deltop addflow aggcgraw delcgraw]
  Example : sub.rb  tcp://192.168.1.8:5555 addcg 

} unless ARGV.length>=2


# parameters 
#
zmq_endpt_sub   = ARGV.shift
cmd   = ARGV.shift


zmq_ctx = ZMQ::Context.new

# add a subscription to Counter Item 
#
s1 = zmq_ctx.socket(ZMQ::REQ)
s1.connect(zmq_endpt_sub)


req= case cmd

when  "addcg"
	mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :context_name => "default",
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
					 :guid => TrisulRP::Guids::CG_HOST,
					 :key => "C0.A8.01.08")
when "delcg"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :context_name => "default",
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
					 :guid => TrisulRP::Guids::CG_HOST,
					 :key => "C0.A8.01.08")
when "addids"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_ALERT,
					 :guid => TrisulRP::Guids::AG_IDS)
when "delids"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_ALERT,
					 :guid => TrisulRP::Guids::AG_IDS)
when "addtop"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_TOPPER,
					 :guid => TrisulRP::Guids::CG_HOST,
					 :meterid  => 0)
when "deltop"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_TOPPER,
					 :guid => TrisulRP::Guids::CG_HOST )
when "addflow"
	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_FLOW,
					 :guid => TrisulRP::Guids::SG_TCP,
					 :key  => 'p-0050' )
when  "addcgraw"
	raise "addcgraw needs guid key" unless ARGV.length == 2
	mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_SUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
					 :guid => ARGV.shift,
					 :key => ARGV.shift)
when "delcg"
	raise "delcgraw needs guid key" unless ARGV.length == 2

	req =mk_request(TRP::Message::Command::STAB_PUBSUB_CTL,
					 :ctl => TRP::SubscribeCtl::CtlType::CT_UNSUBSCRIBE,
					 :type => TRP::SubscribeCtl::StabberType::ST_COUNTER_ITEM,
					 :guid => ARGV.shift,
					 :key => ARGV.shift)
end

req.destination_node="probe0"
s1.send_string(req.serialize_to_string)





