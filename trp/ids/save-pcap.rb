#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Save a PCAP containing all flows that generated a
# priority 1 alert 
#
# Example 
#  ruby save-pcap TRPHOST TRPPORT 
#
require 'trisulrp'

# Check arguments
raise %q{

  save-pcap.rb - Save pcap of flows gen IDS priority 1 alert 

  Usage 
  save-pcap.rb  trisul-ip trp-port 

  Example
  ruby save-pcap.rb 192.168.1.22 12001 

} unless ARGV.length==2



# helper method, save a given flow to a pcap 
def savepcap(conn,  sessid)

	req = TrisulRP::Protocol.mk_request(
		  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
		  :session =>
			 TRP::FilteredDatagramRequest::BySession.new( 
			  :session_id   => sessid
			)
		  )

	TrisulRP::Protocol.get_response(conn,req) do |fdr|
		  File.open("#{fdr.sha1}.pcap","wb") do |f|
			f.write(fdr.contents)
		  end
		  print "Saved to #{fdr.sha1}.pcap\n"
	end

end


# open a connection to Trisul server from command line args
conn  = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600

# query flows tagged with sn-1 (represents priority 1 alert)
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::QUERY_SESSIONS_REQUEST,
				 { 
					:time_interval => mk_time_interval(tmarr),
					:resolve_keys => false,
					:flowtag  => "sn-1"
				 }
				)


# print matching flows using the print_session_details helper  
get_response(conn,req) do |resp|
	 resp.sessions.each do |item|
	 	savepcap(conn,item.session_id)
	 end
end

def savepcap(conn,  sessid)

	req = TrisulRP::Protocol.mk_request(
		  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
		  :session =>
			 TRP::FilteredDatagramRequest::BySession.new( 
			  :SessionID  => sessid
			)
		  )

	TrisulRP::Protocol.get_response(conn,req) do |fdr|
		  File.open("#{fdr.sha1}.pcap","wb") do |f|
			f.write(fdr.contents)
		  end
		  print "Saved to #{fdr.sha1}.pcap\n"
	end

end


