#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Given a flow id in slice:flowid format, get the pcap 
#
# Usage  
#  ruby pcapforflow TRPHOST TRPPORT sliceid:flowid
#
require 'trisulrp'

# Check arguments
raise %q{
  pcap-for-flowid.rb - Download a PCAP for a flow 


  Example
  ruby pcap-for-flowid  192.168.1.22 12001 1:6,1:7,1:19,1:21  

} unless ARGV.length==3


# open a connection to Trisul server from command line args
conn  = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")

bysession = 	TRP::FilteredDatagramRequest::BySession.new( 
	:session_ids => ARGV.shift.split(',').collect do | sid |
					sessid = sid.split(':').map(&:to_i) 
					TRP::SessionID.new({ :slice_id => sessid[0], :session_id  => sessid[1]})  
				end
)


req = TrisulRP::Protocol.mk_request(
  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
  :session => bysession  
  )

TrisulRP::Protocol.get_response(conn,req) do |fdr|
	  File.open("#{fdr.sha1}.pcap","wb") do |f|
		f.write(fdr.contents)
	  end
	  print "Saved to #{fdr.sha1}.pcap\n"
end

