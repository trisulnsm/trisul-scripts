#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Search *ALL* HTTP objects for matching MD5 
# in last 24 hours. Reconstructs TCP/Decompresses/Dechunks
# while hashing. 
#
# Example 
#  ruby searchmd5.rb 192.168.1.12 12001 md5-list.txt 
#
# Will print out matching flows, you can extract the packets from each of
# those flows using FilteredDatagramRequest(..) 
#
require 'trisulrp'

USAGE = "Usage:   search_md5.rb  TRP-SERVER TRP-PORT MD5-FILE\n" \
        "Example: ruby search_md5.rb 192.168.1.12 12001 md5list.txt " 

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
									:md5list => File.read(ARGV[2])
									            .split("\n")
												.collect {|a| a.strip} )

# print matching flows if any 
get_response(conn,req) do |resp|
	puts "Found #{resp.sessions.size} matches"
	resp.sessions.each_with_index  do | sess, idx  |
		puts "Flow #{sess.slice_id}:#{sess.session_id} #{resp.hints[idx]} "
	end 
end

