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

        cns=[]
        algos=[]
        certs = doc.fullcontent.split("-----END CERTIFICATE-----")
        certs.pop 
        certs.each do |cert|
          keyalg = cert.match(/Public Key Algorithm: (.+)\n/)
          cn = cert.match(/CN=(.+)\n/)
          cns << cn[1] 
          if keyalg[1] == "id-ecPublicKey"
            oid = cert.match(/ASN1 OID: (\S+)/)
            if oid.nil?
              algos << "unnamed_explicit_curve"
            else
              algos << oid[1]
            end 
          else
            algos << keyalg[1]
          end 

        end
        curve_stats[algos.join("/")] ||= 0
        curve_stats[algos.join("/")] += 1
        puts "#{algos.join('/').ljust(30)}     #{cns.join('/')}"
      end
    end 

end 

# totals
puts "\n\nTOTALS\n" 
print "PUBLIC KEY ALGO CHAIN".ljust(40) 
print "COUNT"
puts
curve_stats.each do | k, v |
  puts "#{k.ljust(40)}  #{v}"
end

