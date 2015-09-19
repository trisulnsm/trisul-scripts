# Trisul Remote Protocol TRP Demo script
#
#
# Save all packets in timeframe to a PCAP file 
#
# 
require 'trisulrp'

USAGE = "Usage:   getpackets.rb  ZMQ_ENDPOINT \n" \
        "Example: 1) ruby getpackets.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0\n"\
        "         2) ruby getpackets.rb tcp://localhost:5555" 

# usage 
unless ARGV.length==1
  abort USAGE
end


zmq_endpt = ARGV[0]


# timeinterval 
# for demo we get ALL packets between sep 20 2013 and sep 30 2013
#
tint=TRP::TimeInterval.new ( {
  :from => TRP::Timestamp.new(:tv_sec => Time.new(2013,9,20).tv_sec ),
  :to => TRP::Timestamp.new(:tv_sec => Time.new(2013,9,30).tv_sec )
} )


# create the PCAP request for all IP packets (Ethertype = 0300)
#   to get ip packets use filter expression 
#     "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 
#       ^-- this means link layer countergroup = 0x0800
#
req = TrisulRP::Protocol.mk_request(
      TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
    :disposition => TRP::PcapDisposition::SAVE_ON_SERVER,
      :filter_expression =>
         TRP::FilteredDatagramRequest::ByFilterExpr.new( 
          :time_interval  => tint,
          :filter_expression  => "{9F5AD3A9-C74D-46D8-A8A8-DCDD773730BA}=0800" 
        )
      )


# get the response and save pcap 
#
get_response_zmq(zmq_endpt,req) do |fdr|
  print "Number of bytes = #{fdr.num_bytes}\n"
  print "Number of pkts  = #{fdr.num_datagrams}\n"
  print "Hash            = #{fdr.sha1}\n"

  if fdr.disposition == TRP::PcapDisposition::DOWNLOAD
    File.open("filtered000.pcap","wb") do |f|
    f.write(fdr.contents)
    end
    print "Saved to filtered000.pcap\n"
  elsif fdr.disposition == TRP::PcapDisposition::SAVE_ON_SERVER
    print "Saved on server = #{fdr.path}\n"
  end
end


# Now you can open up filtered000.pcap to view all the matching packets
