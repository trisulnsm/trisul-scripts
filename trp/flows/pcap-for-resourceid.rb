#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
#
#
# Usage  
#  ruby pcap-for-resourceid  TRPHOST TRPPORT sliceid:resid 
#
require 'trisulrp'

# Check arguments
raise %q{
  pcap-for-resourceid.rb - Download a PCAP for a list of resources

  Resources are TLS Certs, HTTP URLs, DNS 


  Example
  ruby pcap-for-resid   192.168.1.22 12001 1:6,1:7,1:19,1:21  

} unless ARGV.length==3


# open a connection to Trisul server from command line args
conn  = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")

by = 	TRP::FilteredDatagramRequest::ByResource.new( 
	:resource_group => "{4EF9DEB9-4332-4867-A667-6A30C5900E9E}",
	:resource_ids  => ARGV.shift.split(',').collect do | sid |
					sessid = sid.split(':').map(&:to_i) 
					TRP::ResourceID.new({ :slice_id => sessid[0], :resource_id  => sessid[1]})  
				end
)


req = TrisulRP::Protocol.mk_request(
  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
  :resource  => by  
  )

TrisulRP::Protocol.get_response(conn,req) do |fdr|
	  File.open("#{fdr.sha1}.pcap","wb") do |f|
		f.write(fdr.contents)
	  end
	  print "Saved to #{fdr.sha1}.pcap\n"
end

