TrisulPlugin = {

	id =  {
		name = "sess group mon - onflush",
		description = "Write to a file full flow details ",
	},

	onload = function()
		T.flowlogfile  = io.open("/tmp/fdetails."..T.contextid,"w")
		T.count=1;
	end,

	onunload=function()
		T.flowlogfile:close() 
	end,


	sg_monitor  = {

	    session_guid = '{99A78737-4B41-4387-8F31-8077DB917336}',

		onbeginflush = function(engine,ts)
			T.flowlogfile:write( "Flushing flows at  ts="..ts.." time="..os.date("%c",ts).."\n")
		end,

		onflush = function(engine,flw)

			local ftuples = flw:flow()

			local start_tm, end_tm = flw:time_window() 

			local fstr = string.format("%5d    %2s  %-15s %-6s %-15s %-6s   %8d %20s  %5d secs\n",
				T.count,
				ftuples:protocol(), 
				ftuples:ipa_readable(), ftuples:porta_readable(),
				ftuples:ipz_readable(), ftuples:portz_readable(),
				flw:az_bytes() + flw:za_bytes(),
				os.date("%c",start_tm), 
				end_tm-start_tm
				);


			T.flowlogfile:write(fstr)

			T.count = T.count + 1 

		end,

		onendflush = function(engine)
			T.flowlogfile:write( "----------------------------------------\n\n");
		end

	},

}
