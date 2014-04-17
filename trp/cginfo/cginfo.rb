# Trisul Remote Protocol TRP Demo script
#
# Counter Group Info
#
# Prints information about all supported couner  groups on a trisul instance
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'


USAGE = "Usage:   cginfo.rb  TRP-SERVER TRP-PORT CGGUID \n" \
        "Example: ruby cginfo.rb 192.168.1.12 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E}" 

raise USAGE unless ARGV.length==3


connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key") do |conn|
    target_guid = ARGV.shift

    req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
                                        :counter_group => target_guid )

	# print a single counter group info
    TrisulRP::Protocol.get_response(conn,req) do |resp|
      resp.group_details.each do |group_detail|
         p "Start Time = #{Time.at(group_detail.time_interval.from.tv_sec)}"
         p "End time = #{Time.at(group_detail.time_interval.to.tv_sec)}"
         p "Bucket Size = #{group_detail.bucket_size}"
         p "Name = " + group_detail.name
         p "GUID = " + group_detail.guid
      end
    end
end
