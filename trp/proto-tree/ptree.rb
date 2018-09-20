# Protocol Tree 
#  script prints out a protocol tree, 
#  Used along with the Protocol Tree LUA plugin 
#  ruby ptree.rb 
#
require 'trisulrp'

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

end

class ProtoTree
  #initaize 
  def initialize
    @tree = {}
    @totals = {}
   
  end

  def check_argv
    if ARGV.length !=1 
      print_usage();
    end
  end

  def print_usage
    puts "ptree.rb - prints a nice protocol tree \n"\
         "ruby ptree.rb ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0 \n"
    exit
  end

  def run()
    check_argv()
    zmq_endpt   = ARGV.shift
    #Get the time interval
    req =TrisulRP::Protocol.mk_request(TRP::Message::Command::TIMESLICES_REQUEST,{get_total_window:true})
    TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) do |resp|
      @windows_fromts = resp.total_window.from.tv_sec
      @windows_tots =  resp.total_window.to.tv_sec
    end

    #get guid from counter group 
    req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,{})

    TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) do |resp|
      @cg = resp.group_details.find{|cg| cg.name  == "Protocol Tree"}
      if @cg.nil?
        puts "Cannot find counter group Protocol Tree"
        return
      end
    end
    #protocol tree bytes

    req = TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_TOPPER_REQUEST,{
        counter_group:@cg.guid,
        meter:0,
        time_interval:mk_time_interval([@windows_fromts,@windows_tots])
    });

    TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) do |resp|
      load_tree(resp,"bytes")
    end

   req = TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_TOPPER_REQUEST,{
        counter_group:@cg.guid,
        meter:1,
        time_interval:mk_time_interval([@windows_fromts,@windows_tots])
    });

    TrisulRP::Protocol.get_response_zmq(zmq_endpt,req) do |resp|
      load_tree(resp,"packets")
    end

    @totals = @tree.delete("SYS:GROUP_TOTALS")
    puts "-"*140
    puts "Protocol".ljust(20)+
         "bytes  ( %total)".rjust(50)+
         " ".rjust(10)+
         "Packets  ( %total)".rjust(40)

    puts "-"*140
           
    print_tree({"total counts"=>@totals},0)
    print_tree(@tree,0)

  end

  def load_tree(topper,meterid)
    topper.keys.each do | topper|
      h = @tree
      topper.label.split('/').each do | key|
        h[key] = h[key] || { }
        h=h[key]
        h[meterid] = ( h[meterid] || 0 ) +  topper.metric.to_i
      end
      h["nodetype"] = 'leaf'
      h["nochild"] = true if topper.label.split('/').length==1

    end
    
  end

  def print_tree(subtree,level)
    totals = @totals
    subtree.sort.reject{|a| a[0]=="bytes" or a[0]=="packets"}.sort{|a,b| b[1]["bytes"]<=>a[1]["bytes"]}.each_with_index do | t,idx|
      if t[0]=="bytes" || t[0]=="packets"
        next
      end
     
     #intentation
      @nested = "" #no nested
      if t[1]["nodetype"] == "leaf" and t[1]["nochild"] !=true
        #leaf node nested as 3
        @nested="  "
      else
        #nested as 0 or 1
        @nested=" "*level 
      end
      if level==0 
        @r_just=42
      end

      bytes_per =   "(#{(t[1]["bytes"].to_f*100/totals["bytes"]).round(2)}%)"
      pkt_per =   "(#{(t[1]["bytes"].to_f*100/totals["bytes"]).round(2)}%)"


      puts "#{@nested}#{t[0].ljust(20)}"\
           "#{t[1]["bytes"].to_s.rjust(40)}"\
           "#{bytes_per.rjust(10)}" \
           "#{t[1]["packets"].to_s.rjust(40)}"\
           "#{pkt_per.rjust(10)}"

      if(t[1]["nodetype"]!="leaf")
        print_tree(t[1],1)
      end
    end
  end

end

ProtoTree.new.run()



# total time interval



#protocol tree toppers  
# toppers - packets 



