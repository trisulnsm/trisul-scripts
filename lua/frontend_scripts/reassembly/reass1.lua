TrisulPlugin = {

	id =  {
		name = "reass1",
		description = "basic TCP  reassemly plugging in ",
	},

	onload = function()


	end,


	reassembly_handler  = {

		--
		-- called when a new flow is seen 
		--
		onnewflow = function(engine, time, flow)
			print( "SCRIPT3 : opened 2 files for " .. flow:id() )
		end,

		--
		-- called when a chunk of reassembled data is available 
		-- 
		--  @dir@        direction of reassembly 0=OUT (same direction as SYN) 1=IN 
		--  @buff@       the reassembled bytes are available in this buffer object 
		-- 	@seekpos@    offset in the overall reassembled payload 
		--
		--
		onpayload  = function(engine, time, flow, dir, seekpos, buff )
			print( "SCRIPT3: payload "..flow:porta_readable().." size = "..buff:size().." seekpos="..seekpos .." edir="..dir);

		end,

		--
		-- called when a flow terminates or is timed out 
		--
		onterminateflow  = function(engine, time, flow)
			print( "SCRIPT3 : closing " .. flow:porta_readable ())
		end,


	},

}
