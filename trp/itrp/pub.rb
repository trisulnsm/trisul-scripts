# Trisul Remote Protocol TRP Demo script
#
# Test the public sub interface 
#
# ruby pubsub.rb tcp://192.168.1.8:5555  
#
#
require 'trisulrp'

# Check arguments
raise %q{


  pub.rb - test the pubsub interface 

  Usage   : pub.rb  trisul-zmq-endpt-pub 
  Example : pub.rb  tcp://192.168.1.8:5555

} unless ARGV.length==1


# parameters 
#
zmq_endpt_pub   = ARGV.shift

zmq_ctx = ZMQ::Context.new


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


