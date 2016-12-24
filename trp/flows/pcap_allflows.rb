#!/usr/local/bin/ruby
#
# Saves a PCAP of each flow into a separate PCAP file named cnt-flowid.pcap
# Demonstrates connection to domain and downloading PCAPs
# 
#
require 'trisulrp'
require 'fileutils'

OUTPUTDIR="/tmp/kk"

USAGE = "Usage:   pcap_allflows.rb  ZMQ_DOMAIN_ENDPOINT key=value \n" \
        "Example: 1) ruby pcap_allflows.rb ipc:///usr/local/var/lib/trisul-hub/domain0/run/ctl_local_req source_ip=C0.A8.01.01\n"\

# usage 
unless ARGV.length>=2
  abort USAGE
end



# step 1 : from domain get the TRP Query end point 
# ZMQ domain point
zmq_dom_endpt= ARGV.shift
resp=get_response_zmq(zmq_dom_endpt,
				TrisulRP::Protocol.mk_request(
					TRP::Message::Command::CONTEXT_CONFIG_REQUEST,
					:context_name => 'default'));

zmq_qry_endpt =  resp.endpoints_query.first 




# process query session arguments  into a hash 
qhash = ARGV.inject({}) do |acc,i|
  qparts = i.split("=")
  acc.store( qparts[0].to_sym, qparts[1])
  acc
end

# send query session request
req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::QUERY_SESSIONS_REQUEST,
        qhash.merge( { 
          :time_interval => TrisulRP::Protocol.get_available_time(zmq_qry_endpt),
          :resolve_keys => true,
          :maxitems=>20
        })
      )


# ensure output dir
Dir.mkdir(OUTPUTDIR) if not Dir.exists?(OUTPUTDIR)

get_response_zmq(zmq_qry_endpt,req) do |resp|
  resp.sessions.each do |item|


    #make pcap request
    tmarr = [Time.at(item.time_interval.from.tv_sec-10),Time.at(item.time_interval.to.tv_sec+10)]
    key = "#{item.protocol.key}A:#{item.key1A.key}:#{item.key2A.key}_#{item.key1Z.key}:#{item.key2Z.key}"


     pcap_req = TrisulRP::Protocol.mk_request( 
	 		TRP::Message::Command::PCAP_REQUEST, 
				{
					:context_name=>"default",
					:time_interval => tmarr,
					:filter_expression=>"{99A78737-4B41-4387-8F31-8077DB917336}=#{key}",
					:destination_node=>item.probe_id,
					:max_bytes=>1000000,
			  	});

     resp=get_response_zmq_async(zmq_dom_endpt, pcap_req)

     pcap_output="/tmp/kk/pcap_#{item.session_id.gsub(".","_")}.pcap"
     File.open(pcap_output,"wb"){|f| f.write(resp.contents)}
     fs=File.size(pcap_output)

	 expectsize = 16 * ( item.az_packets + item.za_packets) + 24 + item.az_bytes + item.za_bytes 
     print "#{pcap_output}  #{fs} #{expectsize}   #{item.az_bytes + item.za_bytes}  #{item.az_packets + item.za_packets}   #{key}  #{Time.at(item.time_interval.from.tv_sec)}\n"

  end
end



