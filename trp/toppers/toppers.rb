# Trisul Remote Protocol TRP Demo script
#
# Counter Group Info
#
# Prints topper for the particular counter group for any  meter in specified time range
# 
#  ruby topper.rb 192.168.1.45 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}
#
require 'trisulrp'

# Check arguments
raise %q{


  topper.rb - Retrieve toppers for any counter and stat

  Usage   : topper.rb  trisul-ip trp-port cgguid meter-id
  Example : ruby topper.rb 192.168.1.45 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} 0

  The example retrieves toppers for Apps (guid {C51..}) and meter 0 (total bytes)

} unless ARGV.length==4


# Connect w/ cert and private key 
TrisulRP::Protocol.connect(ARGV.shift,ARGV.shift,
                          "Demo_Client.crt","Demo_Client.key") do |conn|

    # parameters 
    target_guid  = ARGV.shift
    target_meter = ARGV.shift

    # last 24 hours
    tmarr= TrisulRP::Protocol.get_available_time(conn)
    tmarr[0] = tmarr[1] - 24*3600 

    # get topper bucket size - multiply metric by that 
    req = mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
                     :counter_group => target_guid )
    resp = TrisulRP::Protocol.get_response(conn,req)
    target_bucket_size = resp.group_details[0].topper_bucket_size


    # get keys
    req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_REQUEST,
         :counter_group => target_guid,
         :meter => target_meter.to_i,
         :time_interval =>  mk_time_interval(tmarr))

    TrisulRP::Protocol.get_response(conn,req) do |resp|
          print "Counter Group = #{resp.counter_group}\n"
          print "Meter = #{resp.meter}\n"
          resp.keys.each do |key|
              total_bytes = key.metric * target_bucket_size
              print "Key = #{key.key} Label = #{key.label}  Metric= #{total_bytes}\n"
          end
    end
end
