#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Save a PCAP containing all flows that generated a
# priority 1 alert 
#
# We have previously set up a flow tagger that marked
# all flows with the alert priority. We simply query
# those flows and use the TRP Method FILTERED_DATAGRAMS
# to retrieve a merged PCAP of those flows 
#
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


# open a connection to Trisul server from command line args
# you need password of private key (hint: it is 'client' by default) 
conn  = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")


# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600


# Create a TRP Request  
# get all the flows tagged with "sn-1"
# you need to set up a flow tagger to mark flows in this manner
# we mark resolve_keys to false, because we arent interested in
# host and application names as such
#
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::QUERY_SESSIONS_REQUEST,
				 { 
					:time_interval => mk_time_interval(tmarr),
					:resolve_keys => false,
					:flowtag  => "sn-1"
				 }
				)


# Get a response and collect all the session_id in the
# variable sids 
resp  = get_response(conn,req) 
sids = resp.sessions.collect { | e |   e.session_id } 


# Create a TRP Request
# Get all packets belonging to marked flows 
req = TrisulRP::Protocol.mk_request(
	  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
	  :session =>
		 TRP::FilteredDatagramRequest::BySession.new( 
		  :session_ids   => sids
		)
	  )


# Process the response
# Save the matching packets into a file whose name
# is the SHA1 hash of the file contents 
TrisulRP::Protocol.get_response(conn,req) do |fdr|
	  File.open("#{fdr.sha1}.pcap","wb") do |f|
		f.write(fdr.contents)
	  end
	  print "Saved to #{fdr.sha1}.pcap\n"
end


