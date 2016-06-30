-- reass_filter.lua
--  	shows how you can use the "filter" method to 
--  	control which flows you want to reassemble 
--
TrisulPlugin = {

	id =  {
		name = "reass_filter",
		description = "Only interested in reassembly of particular flows ",
	},


	reassembly_handler  = {

		-- only interested in reassembling flows involving this IP address
		-- by using the filter method you save a CPU cycles and memory on  the 
		-- Trisul frontend pipeline
		--  in this example - we only want to reassembly from/to one IP address 
		--
		--  read the docs : return true = yes, we are interested in this one 
		--
		filter = function(engine, time, flow)
			if flow:ipa_readable() == "209.216.249.58" or
			   flow:ipz_readable() == "209.216.249.58" then
				return true
			else
				return false
			end 
		end,

		-- a new flow has started
		-- due to the filter, only flows involving that IP generate this callback
		-- we just print the IP 
		onnewflow = function(engine, time, flow)
			local fstr = string.format("%2s  %-15s %-6s %-15s %-6s   %20s  \n",
				flow:protocol(), 
				flow:ipa_readable(), flow:porta_readable(),
				flow:ipz_readable(), flow:portz_readable(),
				os.date("%c",time) 
				);
			print( "SCRIPT2 : new flow" .. fstr)
		end,

		-- do some interestig things with the reassembled payload 
		-- that are streaming through this function 
		onpayload  = function(engine, time, flow, dir, seekpos, buff )
			print( flow:id())
		end,

		-- some clean up here 
		onterminateflow  = function(engine, time, flow)
			print( "SCRIPT2 : terminated flow" .. flow:id())
		end,


	},

}
