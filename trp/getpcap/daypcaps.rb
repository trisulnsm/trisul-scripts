# Trisul Remote Protocol TRP Demo script
#
# get all pcaps in a given month, one file per day ..
# save on server
# 
require 'trisulrp'
require 'date'

USAGE = "Usage:   daypcaps.rb  ZMQ_ENDPOINT\n" \
        "Example: 1) ruby daypcaps.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0\n"\
        "         2) ruby daypcaps.rb tcp://localhost:5555" 

# usage 
unless ARGV.length==1
  abort USAGE
end


zmq_endpt = ARGV[0]

print "Enter month (YYYY-MM) : "
fd = STDIN.readline.split('-')
dstart = Date.new(*fd.map(&:to_i))

(dstart..dstart.next_month).each  do|day|
  print "\nProcessing Date   = #{day.to_s}\n"

  tint=TRP::TimeInterval.new ( {
    :from => TRP::Timestamp.new(:tv_sec => day.to_time.tv_sec ),
    :to => TRP::Timestamp.new(:tv_sec => day.next_day.to_time.tv_sec)
  } )


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
    print "Finished Date   = #{day.to_s}\n"
    print "Number of bytes = #{fdr.num_bytes}\n"
    print "Number of pkts  = #{fdr.num_datagrams}\n"
    print "Hash            = #{fdr.sha1}\n"
    print "Saved pcap file on server = #{fdr.path}\n"
  end


end

