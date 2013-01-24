#!/usr/local/bin/ruby
# Trisul Remote Protocol TRP Demo script
#
# Print hourly statistics of any counter
#
# You need to know the following
#  - Counter Group ID of the counter 
#  - Meter ID within the Counter Group
#  - Key identifying the entity 
#
# Example 
#  ruby hstats.rb 192.168.1.12 12001 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-0050 0
#
# Will print out hourly stats of HTTP (p-0050) within Apps (GUID C-51..) and meter Total(0)
#
require 'trisulrp'


# usage 
raise "Usage: hourlystats.rb  TRP-SERVER TRP-PORT CGGUID CGKEY METER" unless ARGV.size==5

# open a connection to Trisul server from command line args
conn = TrisulRP::Protocol.connect(ARGV[0],ARGV[1],"Demo_Client.crt","Demo_Client.key")

# storage bins of width 3 hours each 
BINSIZEHOURS = 3 
tmarr  = TrisulRP::Protocol.get_available_time(conn)
end_date=Time.at(tmarr[1])


# collect time intervals you are going to request from Trisul
# we will then send a request for each time interval in the next loop
end_date=Time.mktime(end_date.year,end_date.month,end_date.day+1)
intervals = 7.times.collect  do |d|
  (24/BINSIZEHOURS).times.collect do |h|
    to_date=end_date
    end_date=end_date-3600*BINSIZEHOURS    
    mk_time_interval( [ end_date, to_date] )
  end
end


# For Each Interval print output as they are made available by Trisul
# So this does not wait till all data is computed ..
first_time=true
intervals.each do |dh|

  # column header with times
  if first_time
    print "Day/Hour".rjust(10)+"|"
    dh.reverse.each { |t| print Time.at(t.to.tv_sec).strftime("%H:%M").rjust(10) + "|" }
    print "\n"
    first_time=false
  end

  print Time.at(dh.last.to.tv_sec).strftime("%F").rjust(10) + "|"
  dh.reverse.each do |hourly_interval|
    req = TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
                                                :counter_group=> ARGV[2],
                                                :meter=>ARGV[4].to_i,
                                                :key=>ARGV[3],
                                                :time_interval => hourly_interval)
    get_response(conn,req) do |resp|
          volume  = resp.stats.meters[0].values.inject(0) do |acc,stat|
            acc + stat.val * 30
          end
          print volume.to_s.rjust(10) + "|"
    end 
  end

  print "\n"
end

