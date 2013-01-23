# Trisul Remote Protocol TRP Demo script
#
# helloworld - connect to a Trisul sensor and print sensor ID
#
# Usage ruby  hello.rb  <ip address of trisul sensor> 
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'rubygems'
require 'trisulrp'

raise "Usage: hello.rb <ipaddress>" unless ARGV.size == 1

connect(ARGV[0],
		12001,
        "Demo_Client.crt",
        "Demo_Client.key") do |conn|

             p "Connection success"

             req = mk_request(TRP::Message::Command::HELLO_REQUEST,
                              :station_id => "MyAutomationProg")

             get_response(conn,req) do |resp|

                 p resp.trisul_id
                 p resp.connection_id
                 p resp.version_string

             end
end
