# Trisul Remote Protocol TRP Demo script
#
#
# Save PCAPs of all YouTube videos in last 24 hours 
#

require 'trisulrp'

USAGE = "Usage   : youtube_vids.rb  ZMQ_ENDPOINT\n"\
        "Examples: 1) ruby youtube_vids.rb tcp://localhost:5555\n "\
        "          2) ruby youtube_vids.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0"

# usage 
unless ARGV.size==1
  abort USAGE
end

# ZMQ_ENDPOINT
zmq_endpt = ARGV.shift
# get available time window , tmarr contains [from_time, to_time]
# then set the time window to be latest 24 hours
tmarr  = get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600


# get resources matching "vidplayer"
# Use the RESOURCE_GROUP_REQUEST for URLs
req = mk_request(TRP::Message::Command::RESOURCE_GROUP_REQUEST,
            :resource_group => RG_URL,
            :uri_pattern => "videoplayback" ,
            :time_interval => mk_time_interval(tmarr))


get_response_zmq(zmq_endpt,req) do | matching_resources |

    # matching_resources is a ResourceGroupResponse object
    # containing an array of ResourceItem matches
    matching_resources.resources.each do | res_item  |

        # PCAP request  for each of these using FilteredDatagramRequest
        pcap_req = mk_request(TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
                        :resource => TRP::FilteredDatagramRequest::ByResource.new(
                                    :resource_group => RG_URL,
                                    :resource_id   => res_item))
                                

        get_response_zmq(zmq_endpt,pcap_req) do | pcap |

            # Open and write the pcap file, 
            # filename is the SHA1-Hash
            File.open(pcap.sha1 + ".pcap", "wb" ) do |f|
                f.write(pcap.contents)
                puts "Wrote  #{f.path}"
            end

        end

    end

end

