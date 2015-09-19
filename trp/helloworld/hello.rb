# Trisul Remote Protocol TRP Demo script
#
# helloworld - connect to a Trisul sensor and print sensor ID
#
# Usage ruby  hello.rb  <ip address of trisul sensor> 
#

require 'trisulrp'


USAGE = "Usage:   hello.rb  ZMQ_ENDPT \n" \
        "Example: 1) ruby hello.rb tcp://localhost:5555 \n"\
        "         2) ruby hello.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0" 

# usage 
unless ARGV.size==1
  abort USAGE
end
zmq_endpt = ARGV[0]

req = mk_request(TRP::Message::Command::HELLO_REQUEST,
                          :station_id => "MyAutomationProg")

get_response_zmq(zmq_endpt,req) do |resp|
  p resp.trisul_id
  p resp.connection_id
  p resp.version_string

 end

