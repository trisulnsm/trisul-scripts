# trp script 

require 'trisulrp'

def usage
  p "Wrong number of arguments"
  p "Usage : ruby #{$PROGRAM_NAME} <trp_zmq_endpoint> <path_to_apache_log_file> <path_to_jahash_lua_log>"
  p "Example : ruby #{$PROGRAM_NAME} tcp://74.207.234.90:12006 '/var/log/apache2/trisul_access*' '/usr/local/var/log/trisul-probe/domain0/probeTRISUL/context0/lua.stdout.jahash.lua*'"
end

def get_ja3json
  ja3_hash = {}
  trp_connection = ARGV[0]
  access_log = ARGV[1]
  jahash_log = ARGV[2]
  #get all ja3print
  tint = TrisulRP::Protocol.get_available_time(trp_connection,10)
  tint = TrisulRP::Protocol.mk_time_interval(tint)
  tint.from.tv_sec = tint.to.tv_sec - 86400
  #build trp request
  trp_command = TRP::Message::Command::COUNTER_GROUP_TOPPER_REQUEST
  opts = { counter_group:"{E8D5E68F-B320-49F3-C83D-66751C3B485F}",time_interval:tint,maxitems:25}
  req = TrisulRP::Protocol.mk_request(trp_command, opts)
  resp = get_response_zmq_async(trp_connection,req)
  resp.keys.each do |keyt | 
    next if keyt.key  == "SYS:GROUP_TOTALS"  or keyt.readable != keyt.label
    #mk_edge request 
    p "Sending edge graph request key = #{keyt.key}"
    trp_command = TRP::Message::Command::GRAPH_REQUEST
    opts = { subject_group:"{E8D5E68F-B320-49F3-C83D-66751C3B485F}",time_interval:tint,subject_key:TRP::KeyT.new({key:keyt.key})}
    req = TrisulRP::Protocol.mk_request(trp_command, opts)
    resp_edge = get_response_zmq_async(trp_connection,req)
    keys  = []
    resp_edge.graphs.each do |graph|
      graph.vertex_groups.each do | vertex|
        next if  vertex.vertex_group  != "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}"
        keys << vertex.vertex_keys.collect{|k| k.readable}
      end
    end
     key = keys.flatten.uniq.reject{|k| k=="138.68.45.27"}.each do |key|
       alog = %x(grep -h #{key} #{access_log} | head -1)
       desc = alog.scan(/Mozilla.*/).first
       next if desc.nil?
       desc = desc.gsub('"',"")
       jlog =  %x(grep -h #{key} #{jahash_log} | head -1)
       if jlog =~/UNKNOWN/
         ja3 = jlog.scan(/=(.*)string=(.*)/)
       else
         ja3 = jlog.scan(/hash(.*)string=(.*)/)
       end
       ja3 = ja3.flatten.collect{|text| text.strip}
       unless ja3_hash.has_key? ja3[0]
        ja3_hash[ja3[0]] = {desc:desc,ja3_hash:ja3[0],ja3_str:ja3[1]}
       end
     end
  end
  File.open("/tmp/fingerprint.json","w") do |f|
    ja3_hash.values.each do |ja3|
      f.write(ja3.to_json)
      f.write("\n")
    end
  end
  p "Output written to file /tmp/fingerprint.json"
end

if ARGV.length !=3
  usage
  exit
end
get_ja3json()




