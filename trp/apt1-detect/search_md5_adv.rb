#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# * Advanced version of search_md5.rb 
# 1. Search ALL HTTP objects for matching MD5 
# 2. Print session details 
# 3. Get PCAP of sessions with matching MD5 content 
#
# Example 
#  ruby ruby search_md5_adv.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 md5s.txt
#
#
require 'trisulrp'

USAGE = "Usage   : search_md5_adv.rb  ZMQ_ENDPOINT NAMES-FILE\n"\
        "Examples: 1) ruby search_md5_adv.rb tcp://localhost:5555 md5s.txt \n "\
        "         2) ruby search_md5_adv.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0 md5s.txt"

# usage 
unless ARGV.size==2
  abort USAGE
end


# zmq end point
zmq_endpt  = ARGV[0]

# get 24 hours latest time window 
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 


# send grep request  (GrepRequest)
# read md5s from file given as input 
req = TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
                                      :time_interval => mk_time_interval(tmarr),
                                      :md5list => File.read(ARGV[1])
                                                    .split("\n")
                                                    .collect {|a| a.strip} )

# print matching flows if any 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.sessions.size} matches"
  
  # 1. print matches 
  resp.sessions.each_with_index  do | sess, idx  |
    puts "Flow #{sess.slice_id}:#{sess.session_id} #{resp.hints[idx]} "
  end 

  # 2. print session details (use utility function print_session_details)
  print_session_details(conn,resp.sessions) 

  # 3. for each session save a pcap named after the md5 match 
  resp.sessions.each_with_index  do | sess, idx  |

    pcap_req = TrisulRP::Protocol.mk_request(
                  TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
                    :session  => TRP::FilteredDatagramRequest::BySession.new( 
                    :session_id =>  sess))


    TrisulRP::Protocol.get_response(zmq_endpt,pcap_req) do |fdr|
      File.open(resp.hints[idx] + ".pcap" , "wb" ) do |f|
        f.write(fdr.contents)
      end
      puts "Wrote pcap #{resp.hints[idx]+'.pcap'}"
    end
    
  end 
end

