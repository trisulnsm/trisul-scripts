# Trisul Remote Protocol TRP Demo script
#
#
# Save PCAPs of all YouTube videos in last 24 hours 
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'

raise "Usage : ruby youtube_vids.rb trp_host trp_port" unless ARGV.length==2

# open a TRP connection to the trisul server
#
conn = connect(ARGV.shift,ARGV.shift,"Demo_Client.crt","Demo_Client.key")


# get available time window , tmarr contains [from_time, to_time]
# then set the time window to be latest 24 hours
tmarr  = get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600


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
                                

        get_response(conn,pcap_req) do | pcap |

            # Open and write the pcap file, 
            # filename is the SHA1-Hash
            File.open(pcap.sha1 + ".pcap", "wb" ) do |f|
                f.write(pcap.contents)
                puts "Wrote  #{f.path}"
            end

        end

    end

end

