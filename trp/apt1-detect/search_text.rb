#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search all flows (incl HTTP) for a text pattern
#
# Example 
#  ruby search_text.rb 192.168.1.12 12001 "Install Trisul"
#
#
require 'trisulrp'

USAGE = "Usage:   search_text.rb  TRP-SERVER TRP-PORT String-To-Search \n" \
        "Example: ruby search_text.rb 192.168.1.12 12001 \"hello this is a test \"  " 

# usage 
raise  USAGE  unless ARGV.size==3

# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600 


# send grep request  (GrepRequest)
# read md5s from file given as input 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
                                    :time_interval => mk_time_interval(tmarr),
									:pattern => ARGV[2]  )

# print matching flows if any 
get_response(conn,req) do |resp|
	puts "Found #{resp.sessions.size} matches"
	resp.sessions.each_with_index  do | sess, idx  |
		puts "Flow #{sess.slice_id}:#{sess.session_id} #{resp.hints[idx]} "
	end 
end

