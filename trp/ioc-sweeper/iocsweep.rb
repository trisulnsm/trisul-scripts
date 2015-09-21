#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Consume an Intelligence feed in OpenIOC format 
# then automatically scan past traffic for matches
# for network based indicators 
#
# Example 
#  ruby iocsweep.rb ZMQ_ENDPOINT  openioc-file.ioc
#
#
require 'trisulrp'
require 'nokogiri'

USAGE = "Usage:   iocsweep.rb  ZMQ_ENDPOINT ioc-file.ioc\n" \
        "Example: 1) ruby iocsweep.rb tcp://localhost:5555 469aed6f-941c-4a1e-b471-3a3e80cbcc2e.ioc\n"\
        "         2) ruby iocsweep.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 469aed6f-941c-4a1e-b471-3a3e80cbcc2e.ioc" 
 


# usage 
unless ARGV.size==2
  abort USAGE
end


ioc_doc = Nokogiri::XML(File.read(ARGV[1]))


NETWORK_INDICATORS = %w(PortItem/remoteIP 
                        Network/DNS 
                        Network/URI  
                        Network/String  
                        FileItem/Md5sum)

# grab the indicators
indicator_data = {}
NETWORK_INDICATORS.each do |ind|
  indicator_data[ind]=
    ioc_doc.xpath("//xmlns:IndicatorItem/xmlns:Context[@search='#{ind}']")
      .collect do |a|
        a.parent.at_xpath("xmlns:Content").text
    end
end


# what we found
print "--------------------+-----------\n"
print "Indicator            Count      \n"
print "--------------------+-----------\n"
indicator_data.each do |ind,val|
    print "#{ind.ljust(20)} #{val.size} items \n"
end
print "--------------------+-----------\n"


#Get ZeroMQ end point
zmq_endpt = ARGV[0]

# get recent 24 hrs (in production, sweep over months, one day at a time)
# need to sweep in small intervals so you can stop and continue to get feedback
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 
time_interval =  mk_time_interval(tmarr)


############################################################
# Sweep for IPs 
# Need to normalize IPs into a range compatible with TRP
print "Sweeping for IPs...stand by\n"
ipspaces = indicator_data["PortItem/remoteIP"].collect do |a|
        TRP::KeySpaceRequest::KeySpace.new(
                :from => make_key(a), :to => make_key(a))
end
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::KEYSPACE_REQUEST,
                :counter_group => CG_HOST,
                :time_interval => time_interval,
                :spaces => ipspaces )

# print hits 
get_response_zmq(zmq_endpt,req) do |resp|
    if resp.hits.empty?
        puts "Its clean"
    else 
        puts "Uhoh..Found #{resp.hits.size} these hits, check further"
        resp.hits.each do | res  |
            puts "Hit Key  #{res} "
        end 
    end 
end
print "\n\n"
############################################################


############################################################
# Sweep for Domains  
print "Sweeping for domains...stand by\n"
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_GROUP_REQUEST,
                :resource_group => RG_DNS,
                :time_interval => time_interval,
                :uri_list => indicator_data["Network/DNS"])

# print hits 
get_response_zmq(zmq_endpt,req) do |resp|
    if resp.resources.empty?
        puts "We are clean on domains"
    else 
        puts "Uhoh..Found #{resp.resources.size} these hits, check further"
    end 
end
print "\n\n"
############################################################

############################################################
# Sweep for URI  
print "Sweeping for url content...stand by\n"
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_GROUP_REQUEST,
                :resource_group => RG_URL,
                :time_interval => time_interval,
                :uri_list => indicator_data["Network/URI"])

# print hits 
get_response_zmq(zmq_endpt,req) do |resp|
    if resp.resources.empty?
        puts "All good on HTTP URLs "
    else 
        puts "Uhoh..Found #{resp.resources.size} these hits, check further"
    end 
end
print "\n\n"
############################################################




############################################################
# Check all content for one pattern at a time.
# Currently Trisul 3.0.1325 does not support multiple str searches


indicator_data["Network/String"].each do |patt|

    print "Checking for [#{patt}]. Get a beverage, its going to be a while..\n"
    

    req = TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
                                        :time_interval => mk_time_interval(tmarr),
                                        :pattern => patt   )

    # print matching flows if any 
    get_response_zmq(zmq_endpt,req) do |resp|
        if resp.sessions.empty?
            puts "All good, nothing to see here"
        else 
            puts "Found #{resp.sessions.size} matches"
            resp.sessions.each_with_index  do | sess, idx  |
                puts "Flow #{sess.slice_id}:#{sess.session_id} #{resp.hints[idx]} "
            end 
        end

    end

    print "\n"


end

############################################################
# Check all content for MD5 match
print "Checking all files after reassembly for MD5 match ...get lunch. Could take a while\n"
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
                                    :time_interval => time_interval,
                                    :md5list => indicator_data["FileItem/Md5sum"] )
get_response_zmq(zmq_endpt,req) do |resp|
    if resp.sessions.empty?
        puts "Whew! All files MD5 are clean, also check your endpoints"
    else 
        puts "Dang..MD5 matches #{resp.sessions.size}, log into Trisul and check further"
    end 
end

print "\n\n"
############################################################

