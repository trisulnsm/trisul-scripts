#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search flows by any two combinations 
#
# Example 
#  ruby flows_2.rb 192.168.1.12 12001 [IP|PORT] [IP|PORT]
#
# Will print out matching flows, you can extract the packets from each of
# those flows using FilteredDatagramRequest(..) 
#
require 'trisulrp'

USAGE = "Usage:   flows_2.rb  TRP-SERVER TRP-PORT [IP|PORT] [IP|PORT] \n" \
        "Example: ruby flows_2.rb 192.168.1.12 12001 youtube.com 192.168.1.2" 

# usage 
raise  USAGE  unless ARGV.size==4

# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get 48 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 48*3600 

# make keys (convert names/human readable into trisul)
# if no conversion possible then try interchanging host/port
k1 = mk_trisul_key(conn,CG_HOST,ARGV[2])
if k1==ARGV[2]
	k1 = mk_trisul_key(conn,CG_APP,ARGV[2])
end

k2 = mk_trisul_key(conn,CG_HOST,ARGV[3])
if k2==ARGV[3]
	k2 = mk_trisul_key(conn,CG_APP,ARGV[3])
end 


# send  KEY_SESSION_ACTIVITY_REQUEST 
# read md5s from file given as input 
req = TrisulRP::Protocol.mk_request(
               TRP::Message::Command::KEY_SESS_ACTIVITY_REQUEST,
			   :time_interval => mk_time_interval(tmarr),
			   :key => k1,
			   :key2 => k2)

# print matching flows if any 
get_response(conn,req) do |resp|
	puts "Found #{resp.sessions.size} matches"
	resp.sessions.each_with_index  do | sess, idx  |
		puts "Flow #{sess.slice_id}:#{sess.session_id}"

		# once you have the sess_id you can pull out packets etc.. 
		# see other samples 
	end 
end

