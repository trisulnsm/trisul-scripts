# Trisul Remote Protocol TRP Demo script
#
#
# Insecure helloworld.rb from ../helloworld 
#
# If you want a plain TRP connection, not protected by
# TLS auth and privacy features. You can use the 
# connect_nonsecure(..) method.
#
# This isnt recommended, but it is possible. 
#
# Usage ruby  hello.rb  <ip address of trisul sensor> 
#
require 'trisulrp'

raise "Usage: hello.rb <ipaddress>" unless ARGV.size == 1

connect_nonsecure(ARGV[0], 12001) do |conn|

             p "Connection success"

             req = mk_request(TRP::Message::Command::HELLO_REQUEST,
                              :station_id => "MyAutomationProg")

             get_response(conn,req) do |resp|

                 p resp.trisul_id
                 p resp.connection_id
                 p resp.version_string

             end
end
