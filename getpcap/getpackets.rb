# Trisul Remote Protocol TRP Demo script
#
#
# Save all packets in timeframe to a PCAP file 
#
# 
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'


raise "Usage : getpackets trp_host trp_port " unless ARGV.length==2

# open a TRP connection to the trisul server
#
conn = TrisulRP::Protocol.connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")


# timeinterval 
# for demo we get ALL packets between sep 20 2013 and sep 30 2013
#
tint=TRP::TimeInterval.new ( {
  :from => TRP::Timestamp.new(:tv_sec => Time.new(2013,9,20).tv_sec :tv_usec=>0),
  :to => TRP::Timestamp.new(:tv_sec => Time.new(2013,9,30).tv_sec, :tv_usec=>0)
} )


# create the PCAP request for all IP packets (Ethertype = 0300)
#   to get ip packets use filter expression 
#     "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 
#       ^-- this means link layer countergroup = 0x0800
#
req = TrisulRP::Protocol.mk_request(
      TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
      :filter_expression =>
         TRP::FilteredDatagramRequest::ByFilterExpr.new( 
          :time_interval  => tint,
          :filter_expression  => "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 
        )
      )


# get the response and save pcap 
#
TrisulRP::Protocol.get_response(conn,req) do |fdr|
  print "Number of bytes = #{fdr.num_bytes}\n"
  print "Number of pkts  = #{fdr.num_datagrams}\n"
  print "Hash            = #{fdr.sha1}\n"
  print "Saved to filtered000.pcap\n"

  File.open("filtered000.pcap","wb") do |f|
    f.write(fdr.contents)
  end
end


# Now you can open up filtered000.pcap to view all the matching packets
