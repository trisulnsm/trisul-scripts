# Trisul Remote Protocol TRP Demo script
#
#
# Print Cert Chains from particular IP
#
require 'rubygems' if RUBY_VERSION < '1.9'
require 'trisulrp'



# investigate_certs
#   1. Connect to a trisul probe with demo certs
#   2. For the past 1 month
#   3. Search for all HTTPS flows for a particular host
#   4. Print the cert chain of each flow 
#
def investigate_certs(zmq_endpt, target_host, target_app)


    # open a TRP connection to the trisul server
    #
    zmq_endpt = zmq_endpt

    # user wants to see flows for this  hostname
    #
    target_ip   = mk_trisul_key(zmq_endpt,CG_HOST,  target_host )
    target_port = mk_trisul_key(zmq_endpt,CG_APP,   target_app )


    # get available time window , tmarr contains [from_time, to_time]
    tmarr  = TrisulRP::Protocol.get_available_time(zmq_endpt)


    # send request for sessions for key
    req = TrisulRP::Protocol.mk_request(TRP::Message::Command::KEY_SESS_ACTIVITY_REQUEST,
                                          :key => target_ip ,
                                          :key2 => target_port ,
                                          :maxitems => 20 ,
                                          :time_interval => mk_time_interval(tmarr))


    # response 
    get_response_zmq(zmq_endpt,req) do |resp|


      # for each flow get first 20K pcap
      resp.sessions.each do |sess|

        getpackets  = TrisulRP::Protocol.mk_request(TRP::Message::Command::FILTERED_DATAGRAMS_REQUEST,
                                                    :max_bytes => 20000,
                                                    :session => TRP::FilteredDatagramRequest::BySession.new( :session_id =>  sess))


        get_response_zmq(zmq_endpt,getpackets) do |fdr|
            pcapf = fdr.sha1 + ".pcap"
            File.open(pcapf, "wb" ) do |f|
                f.write(fdr.contents)
            end
            print_cert_stack(pcapf)
        end
      end 
    end
end


###
### below this 
### same as Part 1 - sample - calls Unsniff Scripting API to print Cert Stack from PCAP 
#
require 'win32ole'

# enumerable helper
class UWrap
  include Enumerable
  def initialize(w)
    @wrapped=w
  end
  def each(&block)
    @wrapped.each { |m| block.call(m) }
  end
end


# print_cert_stack
#  Scan the pcap file and print the cert chain
#  = commonName + organizationName for each issuer/subject in chain
#  This is the same code as csx.rb in Step 1, except it has been
#  made into a method and Imports a PCAP file instead of working
#  directly with a USNF file 
#
def print_cert_stack(pcap_file)

    unsniffDB = WIN32OLE.new("Unsniff.Database")

    File.delete("temp.usnf") if File.exists? "temp.usnf"
    unsniffDB.New("temp.usnf")
    unsniffDB.Import("libpcap", pcap_file )


    # print cert stack of each cerficate pdu
    unsniffDB.PDUIndex.each  do |pdu|
          next unless pdu.Description =~ /Server Certificate/  


      print "\nCertificate chain for " + pdu.SenderAddress   + " to " + pdu.ReceiverAddress + "\n"


      handshake = UWrap.new(pdu.Fields).find do |f|
          hst = f.FindField("Handshake Type")
          hst and  hst.Value() == "11 (certificate)"
      end

      next unless handshake

      certstack = handshake.FindField("Certificate")


      certs = UWrap.new(certstack.SubFields).select { |f| f.Name == "ASN.1Cert" }

      indent =  4
      certs.each do |cert|
        subject = cert.FindField("subject")
        issuer = cert.FindField("issuer")

        sub,iss = {},{}

        [ [subject, sub], [issuer, iss] ].each do |a|
          a[0].SubFields.each  do |rdn|

        case rdn.FindField("type").Value 
          when /commonName/ 
            a[1][:cn]=rdn.FindField("DirectoryString").Value 
            ;
              
          when /organizationName/ 
            a[1][:on]=rdn.FindField("DirectoryString").Value 
            ;
        end
          end
        end
        print "  "*indent     + "#{sub[:cn]} (#{sub[:on]})\n"
        print "  "*(indent+1) +  "#{iss[:cn]} (#{iss[:on]})\n"
        indent = indent + 1

      end

    end


    unsniffDB.Close


end



USAGE = "Usage   : certx.rb  ZMQ_ENDPOINT host port\n"\
        "Examples: 1) ruby certx.rb tcp://localhost:5555 host port\n "\
        "         2) ruby certx.rb ipc:///usr/local/var/lib/trisul/CONTEXT0/run/trp_0  host port"

# usage 
unless ARGV.size==3
  abort USAGE
end

# kick this off 
investigate_certs(ARGV.shift,ARGV.shift,ARGV.shift) 

