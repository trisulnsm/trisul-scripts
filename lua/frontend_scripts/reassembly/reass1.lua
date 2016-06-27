TrisulPlugin = {

	id =  {
		name = "reass1",
		description = "basic TCP  reassemly plugging in ",
	},

	onload = function()

		T.flowfiles = { } 

	end,


	reassembly_handler  = {

		-- only interested in reassembling flows involving this IP address
		--
		filter = function(engine, time, flow)
			return true
		end,

		onnewflow = function(engine, time, flow)

			T.flowfiles[flow:id()] =  { "/tmp/kk/" .. flow:id().."_in", 
										"/tmp/kk/" .. flow:id().."_out" };
			
			print( "SCRIPT3 : opened 2 files for " )
		end,

		onpayload  = function(engine, time, flow, dir, seekpos, buff )
			print("SCRIPT3: payload "..flow:porta_readable().." size = "..buff:size().." seekpos="..seekpos .." edir="..dir);

			local f= T.flowfiles[flow:id()]
		
			local f_in_out = nil;
			if dir==0 then
				f_in_out = f[1]
			else 
				f_in_out = f[2]
			end
			buff:writetofile(f_in_out,seekpos)
		end,

		onterminateflow  = function(engine, time, flow)
			print( "SCRIPT3 : closing " .. flow:porta_readable ())
		end,


	},

}
