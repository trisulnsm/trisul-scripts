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
