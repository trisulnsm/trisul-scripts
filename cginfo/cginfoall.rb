# Trisul Remote Protocol TRP Demo script
#
# Counter Group Info 2 
#
#
# Prints info about all counter groups 
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'


USAGE = "Usage:   cginfoall.rb  TRP-SERVER TRP-PORT \n" \
        "Example: ruby cginfo.rb 192.168.1.12 12001" 

raise USAGE unless ARGV.length==2


connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key") do |conn|
    target_guid = ARGV.shift

    # print info about all counter groups, 
	# note that we have not specified the counter_group guid in the request
	# So all the counter groups are retrieved.
    req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)

    get_response(conn,req) do |resp|
      resp.group_details.each do |group_detail|
         print  group_detail.name.ljust(25)
         print  group_detail.guid
         print " #{Time.at(group_detail.time_interval.from.tv_sec)}  "
         print " #{Time.at(group_detail.time_interval.to.tv_sec)}  "
         print " #{group_detail.bucket_size}  "
		 print "\n"
      end
    end
end
