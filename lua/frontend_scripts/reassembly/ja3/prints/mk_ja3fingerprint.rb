# mk_ja3print
# TRP Script to use Web Server Access log to resolve prints
# 1. Connects to a Trisul system
# 2. Gets Unresolved TLS Fingerprints
# 3. Just greps the web logs and app logs to match based on IP
# 4. Outputs in JSON format compatible with TLS JA3 Print

require 'trisulrp'

def usage
  p "Usage   : ruby #{$PROGRAM_NAME} <trp_zmq_endpoint> <Website-IP>  <Apache-Log-Files-Pattern> <Trisul-App-Log-Pattern> "
  p "Example : ruby #{$PROGRAM_NAME} tcp://74.207.234.90:12006 128.38.38.1 'my_access*' 'lua.stdout.jahash.lua*' "
end

def get_ja3json

  ja3_hash = {}
  trp_connection = ARGV[0]
  webserver_ip = ARGV[1]
  access_log = ARGV[2]
  jahash_log = ARGV[3]

  # script operates over last 24 hours 
  tint = TrisulRP::Protocol.get_available_time(trp_connection,10)
  tint = TrisulRP::Protocol.mk_time_interval(tint)
  tint.from.tv_sec = tint.to.tv_sec - 86400

  # build trp request
  trp_command = TRP::Message::Command::COUNTER_GROUP_TOPPER_REQUEST
  opts = { counter_group:"{E8D5E68F-B320-49F3-C83D-66751C3B485F}",time_interval:tint,maxitems:25}
  req = TrisulRP::Protocol.mk_request(trp_command, opts)
  resp = get_response_zmq_async(trp_connection,req)

  # for unresolved prints the label is the Client Type 
  unresolved_prints = resp.keys.reject do |keyt | 
    keyt.key  == "SYS:GROUP_TOTALS"  or keyt.readable != keyt.label
  end 
  p "Found #{unresolved_prints.size} Unresolved JA3 TLS Prints" 

  # process each print 
  unresolved_prints.each do |keyt | 

    # mk_edge request 
    p "Sending EdgeGraph req for vertex=#{keyt.key}"
    trp_command = TRP::Message::Command::GRAPH_REQUEST
    opts = { subject_group:"{E8D5E68F-B320-49F3-C83D-66751C3B485F}",time_interval:tint,subject_key:TRP::KeyT.new({key:keyt.key})}
    req = TrisulRP::Protocol.mk_request(trp_command, opts)
    resp_edge = get_response_zmq_async(trp_connection,req)
    keys  = []
    
    # list of IPs that used this finger print 
    resp_edge.graphs.each do |graph|
      graph.vertex_groups.each do | vertex|
        next if  vertex.vertex_group  != "{4CD742B1-C1CA-4708-BE78-0FCA2EB01A86}"
        keys << vertex.vertex_keys.collect{|k| k.readable}
      end
    end
    

    # check the IP in web access log as well as the Trisul Lua App log 
    key = keys.flatten.uniq.reject{|k| k==webserver_ip}.each do |key|
       alog = %x(grep -h #{key} #{access_log} | head -1)
       desc = alog.split('"')[-2]
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
        p "#{ja3[0]} resolved to  #{desc}  #{ja3[1]}" 
       end

     end
  end


  # Write in JSON format to output file 
  File.open("/tmp/fingerprint.json","w") do |f|
    ja3_hash.values.each do |ja3|
      f.write(ja3.to_json)
      f.write("\n")
    end
  end

  p "Output written to file /tmp/fingerprint.json"
end

if ARGV.length != 4
  usage
  exit
end

get_ja3json()




