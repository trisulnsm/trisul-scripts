# Trisul Remote Protocol TRP Demo script
#
#
# Save PCAPs of all YouTube videos in last 24 hours 
# Change the file name of each video to the Title of the video 
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'
require 'win32ole'
require 'nokogiri'

raise "Usage : ruby youtube_titles.rb trp_host trp_port" unless ARGV.length==2

# open a TRP connection to the trisul server
#
conn = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")


# get available time window , tmarr contains [from_time, to_time]
# then set the time window to be latest 24 hours
tmarr  = get_available_time(conn)
tmarr[0] = tmarr[1] - 48*3600


# get resources matching "vidplayer"
# Use the RESOURCE_GROUP_REQUEST for URLs
req = mk_request(TRP::Message::Command::RESOURCE_GROUP_REQUEST,
            :resource_group => RG_URL,
            :uri_pattern => "videoplayback" ,
            :time_interval => mk_time_interval(tmarr))


get_response(conn,req) do | matching_resources |

    # matching_resources is a ResourceGroupResponse object
    # containing an array of ResourceItem matches
    matching_resources.resources.each do | res_item  |

        # PCAP request  for each of these using FilteredDatagramRequest
        pcap_req = mk_request(TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
                        :resource => TRP::FilteredDatagramRequest::ByResource.new(
                                    :resource_group => RG_URL,
                                    :resource_id   => res_item))
        pcap = get_response(conn,pcap_req) 

        # Open and write the pcap file, 
        # filename is the SHA1-Hash
        File.open("temp_video.pcap", "wb" ) do |f|
            f.write(pcap.contents)
        end


        # Open the file and find out the referrer 
        refr = nil 
        unsniffDB = WIN32OLE.new("Unsniff.Database")
        File.delete("temp.usnf") if File.exists? "temp.usnf"
        unsniffDB.New("temp.usnf")
        unsniffDB.Import("libpcap", "temp_video.pcap" )
        unsniffDB.PacketIndex.each do |pkt|
            if pkt.Description =~ /^GET/
                refr = pkt.FindLayer("HTTP").FindField("Referer")
                p "Referer = #{refr.Value}"
                break
            end
        end

        # Dump the FLV or WEBM file
        unsniffDB.UserObjectsIndex.each do |uo|
            if uo.Type =~ /FLV|WEBM/
                uo.SaveToFile("temp_video.#{uo.Type}")
            end
        end
        unsniffDB.Close
        File.delete("temp_video.pcap")
            

        # Find the resource matching the HTTP Referrer
        # the referrer contains the <title> we want to use 
        req = mk_request(TRP::Message::Command::RESOURCE_GROUP_REQUEST,
            :resource_group => RG_URL,
            :uri_pattern =>  refr.Value.scan( /http:.*\/(.*)/).flatten.first ,
            :time_interval => mk_time_interval(tmarr))
        vidpages = get_response(conn,req) 

        pcap_req = mk_request(TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
                        :resource => TRP::FilteredDatagramRequest::ByResource.new(
                                    :resource_group => RG_URL,
                                    :resource_id   => vidpages.resources.first)
                        )
                                
        pcap = get_response(conn,pcap_req) 
        File.open("watch.pcap", "wb" ) do |f|
            f.write(pcap.contents)
        end

        # Parse the PCAP containing the Referer, then dump the HTML
        # then load the HTML using Nokogiri and search for the <title>
        #
        video_title = "unknown title #{rand(1000)}"
        unsniffDB = WIN32OLE.new("Unsniff.Database")
        File.delete("temp.usnf") if File.exists? "temp.usnf"
        unsniffDB.New("temp.usnf")
        unsniffDB.Import("libpcap", "watch.pcap" )
        unsniffDB.UserObjectsIndex.each do |uo|
            if uo.Type == "HTML" and uo.Name =~ /watch/
                uo.SaveToFile(uo.PreferredFileName)

                File.open(uo.PreferredFileName) do |f|
                    doc = Nokogiri::XML(f)
                    video_title = doc.xpath("//title").text
                end

                File.delete(uo.PreferredFileName)
            end
        end
        unsniffDB.Close
        File.delete("watch.pcap")


        # remove invalid chars in ntfs filenames 
        # change the file name to the video title 
        video_title.delete!(":&;/?<>\:*|")  
        %w(.flv .webm).each do |ext|
            File.rename("temp_video#{ext}", video_title + ext) if File.exists?("temp_video#{ext}")
        end
        File.delete("temp.usnf")


    end

end

