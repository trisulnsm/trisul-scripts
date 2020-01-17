# Trisul Remote Protocol TRP Demo script
#
# eccerts : scan the last months certificates and check if any 
# cert included explicit parameters 
#
# Usage ruby  eccerts.rb  TRP-server-endpoint 
#
require 'trisulrp'

USAGE = "Usage:   eccerts.rb  ZMQ_ENDPT NUM_DAYS \n" \
        "Example: ruby eccerts.rb tcp://localhost:5555  2 \n"

# usage 
abort USAGE unless ARGV.size==2
zmq_endpt = ARGV.shift 
num_days= ARGV.shift.to_i 

# counters
curve_stats = {} 

# process each day (slice) starting today in reverse... 
each_time_interval(zmq_endpt)  do | tm_interval, slice_id, total_slices |

    break if slice_id >  num_days

    req=mk_request(TRP::Message::Command::QUERY_FTS_REQUEST, {
                    time_interval: tm_interval,
                    fts_group: "{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}",
                    keywords: "id-ecPublicKey"
                  })
    get_response_zmq(zmq_endpt,req) do |resp|

      resp.documents.each do | doc |
        cn = doc.fullcontent.match(/CN=(\S+)/)
        oid = doc.fullcontent.match(/ASN1 OID: (\S+)/)
        if oid.nil?
          curve_name = "unnamed_explicit_curve"
        else 
          curve_name = oid[1]
        end 
        puts " #{curve_name}   #{cn[1]}" 
        curve_stats[curve_name] ||= 0
        curve_stats[curve_name] += 1
      end
    end 

end 

# totals
puts "\n\nTOTALS" 
curve_stats.each do | k, v |
  puts "#{k.ljust(20)}  #{v}"
end

