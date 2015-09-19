#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Run all certs in past 24 hrs past  the ICSI Certificate Notary 
# --> notary.icsi.berkeley.edu 
#
# 
# Example 
#  ruby checknotary.rb 192.168.1.22 12001 
#
#
require 'trisulrp'
require 'dnsruby'

USAGE = "Usage:   checknotary.rb  ZMQ_ENDPOINT \n" \
        "Example: 1) ruby checknotary.rb tcp://localhost:5555\n"\
        "         2) ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0" 

# usage 
unless ARGV.size==2
  abort USAGE
end

# setup up a DNS resolver
dnss = Dnsruby::DNS.open 

# local cache 
cache = {} 


# Zeromq Connection End Point

zmq_endpt  = ARGV[0]

# get recent 24 hrs
tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)
tmarr[0] = tmarr[1] - 24*3600 

# send resource group request 
# we want resource group RG_SSL  identified by GUID {D1E2..} see docs 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_GROUP_REQUEST,
        :resource_group => RG_SSLCERTS,
        :time_interval => mk_time_interval(tmarr),
        :maxitems => 10000)

# for each resource, check against the notary 
get_response_zmq(zmq_endpt,req) do |resp|
  puts "Found #{resp.resources.size} matches"
  resp.resources.each do | res  |

    req2 = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_ITEM_REQUEST,
        :resource_group => RG_SSLCERTS,
        :resource_ids  => [res] )

    resp2 = get_response(conn,req2)
    resp2.items.each do | resitem |

      cchain = resitem.uri.split("---")
      cchain.each do | cert |
        
        cparts = cert.split("\n")

        cert_sha =  cparts[1][5..-1]
        cert_name =  cparts[2]

        next if cache.has_key? cert_sha
        cache.store(cert_sha,1)


        begin
          domn = "#{cert_sha}.notary.icsi.berkeley.edu"
          print "#{domn}"
          resp = dnss.getresource(domn,"txt")
          if resp.to_s =~ /validated=1/
            print "....[OK VALID]\n"
          else 
            print "....[OK]\n"
            print "    ^-- not validated #{cert_name}\n\n"
          end 

        rescue Dnsruby::NXDomain
          print "....[FAIL - NXDOMAIN]\n"
          print "    ^-- failed #{cert_name}\n\n"
        end

      end


    end

  end 
end

