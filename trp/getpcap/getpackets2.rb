# Trisul Remote Protocol TRP Demo script
#
#
# Save all packets between two days to a PCAP file on the server 
#
# == This version allows you to enter a from date and to date 
#    and  output filename 
# 
require 'trisulrp'

USAGE = "Usage:   getpackets2.rb  ZMQ_ENDPOINT \n" \
        "Example: 1) ruby getpackets2.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0\n"\
        "         2) ruby getpackets2.rb tcp://localhost:5555" 

# usage 
unless ARGV.length==1
  abort USAGE
end

#zeromq end point
zmq_endpt = ARGV[0]

print "Enter FROM date (YYYY-MM-DD) : "
fd = STDIN.readline.split('-')
print "Enter TO   date (YYYY-MM-DD) : "
td = STDIN.readline.split('-')
tint=TRP::TimeInterval.new ( {
  :from => TRP::Timestamp.new(:tv_sec => Time.new(*fd).tv_sec ),
  :to => TRP::Timestamp.new(:tv_sec => Time.new(*td).tv_sec )
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
  print "Saved pcap file on server = #{fdr.path}\n"
end


