#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Consume an Intelligence feed in OpenIOC format 
# then automatically scan past traffic for matches
# for network based indicators 
#
# Example 
#  ruby iocsweep.rb 192.168.1.22 12001  openioc-file.ioc
#
#
require 'trisulrp'
require 'nokogiri'

USAGE = "Usage:   iocsweep.rb  TRP-SERVER TRP-PORT ioc-file.ioc\n" \
        "Example: ruby iocsweep.rb 192.168.1.12 12001 469aed6f-941c-4a1e-b471-3a3e80cbcc2e.ioc" 

# usage 
raise  USAGE  unless ARGV.size==3


# open a connection to Trisul server from command line args
conn  = connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# get recent 24 hrs (in production, sweep over time)
tmarr  = TrisulRP::Protocol.get_available_time(conn)
tmarr[0] = tmarr[1] - 24*3600 

# send resource group request 
# we want resource group RG_SSL  identified by GUID {D1E2..} see docs 
req = TrisulRP::Protocol.mk_request(
                TRP::Message::Command::RESOURCE_GROUP_REQUEST,
				:resource_group => RG_SSLCERTS,
				:time_interval => mk_time_interval(tmarr),
				:maxitems => 10000)

# for each resource, check against the notary 
get_response(conn,req) do |resp|
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

