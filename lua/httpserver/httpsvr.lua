--
-- httpsvr.lua
-- 	
-- 	Counts HTTP traffic per HTTP Server 
-- 	We use flow based counting 
--
TrisulPlugin = {

	id = {
		name = "HTTP Server Counter",
		description = "Meters HTTP server traffic ",
		author = "Unleash",
		version_major = 1,
		version_minor = 0,
	},

	onload = function()
		T.host:log(T.K.loglevel.INFO, "Hi from flow monitor sample ");
	end,


	onunload = function ()
		T.host:log(T.K.loglevel.INFO, "Bye!")
	end,


	countergroup = {

		-- control section
		--   Id of the counter group 
		--   Use an online guid generator to create two unique guids
		control = {
			guid="{0e4281ed-5545-4bf2-94f2-c4027fbc9afa}",
			name = "Web Server",
			description = "Web Server from Server field in HTTP header",
			bucketsize = 30,
		},

		-- meter section
		-- 	What we're trying to count 
		-- 	Here we count bytes and packets 
		meters = {
				{  0, T.K.vartype.RATE_COUNTER, 10, "Bytes", "bytes" , "B" },
				{  1, T.K.vartype.COUNTER, 10, "Hits", "hits" , "H" },
		},

	},


	flowmonitor  = {

		-- onflowattribute
		-- 	called for each flow attribute
		onflowattribute = function(engine,flow,timestamp,
									attribute_name, attribute_value)

			local hdr = attribute_value


			local h = {}
			local htcmd = ""
			if attribute_name == "HTTP-Header" then
				for line  in attribute_value:gmatch("([^\r\n]+)") do 
					local 	k,v = get_kv(line)
					if v == nil then 
						htcmd = v 
					else
						h[k]=v
					end
				end
			end

			local svr = h["Server"]
			if svr then  
				local k = svr:find(' ')  or  -1
				local final_key  = svr:sub(1,k) 
				print("The Web Server is ".. final_key.."orig = "..svr)


				--
				-- reset flow counter attaches a counter to flow
				-- so each packet is automatically metered with this info
				-- until the next reset flow counter is called for that
				-- flow 
				engine:reset_flow_counter( 
						flow:id(), 
						TrisulPlugin.countergroup.control.guid,
						final_key,
						0)

				--
				-- we use update_counter here because we only want to track
				-- "hits" for this meter 
				engine:update_counter( 
						TrisulPlugin.countergroup.control.guid,
						final_key,
						1, 1 )
			end
		end,
	 },
}


function get_kv(s)

	local c1,c2 = s:find("%s*:%s*.*$")

	if c1 == nil then return s,nil end


	local k = s:sub(1,c1-1)
	local v = s:sub(c1+2,-1)

	return k,v
end

