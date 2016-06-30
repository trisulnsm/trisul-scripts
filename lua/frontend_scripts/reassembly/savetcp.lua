-- savetcp.lua
--  save all reassembled TCP stream data into files
--
--   'out direction  reassembled payload in <flowid>_out 
--   'in  direction  reassembled payload in <flowid>_in
--
TrisulPlugin = {

	id =  {
		name = "savetcp",
		description = "app to save reassembled  TCP payloads to file ",
	},

	--
	-- set up a global lookup table ( flowid => [file_in, file_out]  ) 
	--  we need to open TWO files per flow, one for each direction
	--
	onload = function()
		T.flowfiles = { } 
	end,


	reassembly_handler  = {

		-- only interested in reassembling flows involving this IP address
		-- we want everything, but you can apply filter here
		-- see reass_filter.lua  sample 
		filter = function(engine, time, flow)
			return true
		end,

		-- a new flow is established
		-- setup two filenames and store it at the flowid
		--
		onnewflow = function(engine, time, flow)

			T.flowfiles[flow:id()] =  { "/tmp/kk/" .. flow:id().."_in", 
										"/tmp/kk/" .. flow:id().."_out" };
			
			-- print( "SCRIPT3 : opened 2 files IN/OUT " )
		end,


		-- got a payload
		-- lookup the file in which this payload buffer is stored
		-- then store the bytes using the 'writetofile' methods of the
		-- buffer object. You can also use LUA io.write(..) methods, would be longer 
		--
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

		-- flow ends 
		-- nothing interesting here 
		-- if you had opened any files related to the flow you would close them here
		onterminateflow  = function(engine, time, flow)
			print( "SCRIPT3 : closing " .. flow:porta_readable ())
		end,


	},

}
