
#!/usr/local/bin/ruby
#
# SAME AS query-flow.rb but uses ZMQ transport 
# Example 
#  ruby query-flow_zmq zmq:endpoint <opts> 
#
require 'trisulrp'
require 'fileutils'

USAGE = "Usage:   query-flow_zmq.rb  ZMQ_ENDPOINT key=value \n" \
        "Example: 1) ruby query-flow_zmq.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 source_ip=C0.A8.01.01\n"\
        "         2) ruby query-flow_zmq.rb tcp://localhost:5555 source_ip=C0.A8.01.01" 

# usage 
unless ARGV.length>=2
  abort USAGE
end


#ZMQ connection end point
zmq_endpt= ARGV.shift


# process arguments 
qhash = ARGV.inject({}) do |acc,i|
  qparts = i.split("=")
  acc.store( qparts[0].to_sym, qparts[1])
  acc
end

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
#tmarr[0] = tmarr[1] - 24*3600

# send query session request
req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::QUERY_SESSIONS_REQUEST,
        qhash.merge( { 
          :time_interval => mk_time_interval(tmarr),
          :resolve_keys => true,
          :maxcount=>10000
        })
      )


outputdir = "/tmp/savedpcap/"
FileUtils.rm_rf(outputdir) if Dir.exists?(outputdir)
Dir.mkdir(outputdir)

get_response_zmq(zmq_endpt,req) do |resp|
  resp.sessions.each do |item|
    #make pcap request
    tmarr = [Time.at(item.time_interval.from.tv_sec-10),Time.at(item.time_interval.to.tv_sec+10)]
    key = "#{item.protocol.key}A:#{item.key1A.key}:#{item.key2A.key}_#{item.key1Z.key}:#{item.key2Z.key}"
    opts=  {

            :context_name=>"offline",
            :time_interval => mk_time_interval(tmarr),
            :filter_expression=>"{99A78737-4B41-4387-8F31-8077DB917336}=#{key}",
            :destination_node=>item.probe_id,
            :max_bytes=>999999,
            :run_async=>true
          }
     pcap_req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::PCAP_REQUEST,
         opts)
     resp=get_response_zmq("ipc:///usr/local/var/lib/trisul-hub/domain0/run/ctl_local_req",pcap_req)
     trp_resp_command_id = resp.instance_variable_get("@trp_resp_command_id")
     while TRP::Message::Command::ASYNC_RESPONSE == trp_resp_command_id do
      async_req = TrisulRP::Protocol.mk_request(
        TRP::Message::Command::ASYNC_REQUEST,
        {token:resp.token,
          destination_node:item.probe_id,
          sleep:2
        })
       resp=get_response_zmq("ipc:///usr/local/var/lib/trisul-hub/domain0/run/ctl_local_req",async_req) 
       trp_resp_command_id = resp.instance_variable_get("@trp_resp_command_id")
     end 
     outputfile=File.join(outputdir,"pcap_#{item.session_id.gsub(".","_")}.pcap")
     File.open(outputfile,"wb"){|f| f.write(resp.contents)}
     fs=File.size(outputfile)
     if fs <= 0
      p "File size is #{fs},name=#{outputfile},key=#{key},ts=#{Time.at(item.time_interval.from.tv_sec)}"
     end
  end
end



