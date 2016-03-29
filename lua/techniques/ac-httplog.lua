-- ac-httplog.lua
--
-- HTTP Logger , this time using Aho-Corasik T.ac(..) 
-- 
--
--
--

require ("queue")

TrisulPlugin = {

  id = {
    name = "HTTP Logger ",
    description = "Log req/resp in one line ",
    author = "Unleash", version_major = 1,
    version_minor = 0,
  },



  onload = function () 
   math.randomseed(os.time())
    P = TrisulPlugin

	P.ahoc  = {

		-- add patterns in HTTP requests
		-- 
		requests   = T.ac({ "Host:",
							"User-Agent:",
							"Referer"}),

		-- add patterns in HTTP responses 
		-- 
		responses  = T.ac({ "HTTP/1.",
							"Server:", 
							"Content-Type:", 
							"Content-Length:"} )

	}

	P.flowmap = { } 

	local fn="/tmp/httpheaders-"..math.random(10000)
	P.outfile = io.open(fn,"w");

  end,


  onunload = function()

  	P.outfile.close()
	P.outfile = nil 

  end,


  flowmonitor  = {

	onflowattribute = function(engine,flow,timestamp,
							   nm, valobj)

		 if nm == "^D" then
		 	local flowkey = flow:id()
			P.flowmap[flowkey] = P.flowmap[flowkey] or queue.new()
			return
		 end



	     if nm == "HTTP-Header" then

		 	local val = valobj:tostring() 

		 	local flowkey = flow:id()
			P.flowmap[flowkey] = P.flowmap[flowkey] or queue.new()
			local q = P.flowmap[flowkey]



		 	if val:find("^HTTP/") then

				local a =  q:popfirst()

				if not a then return; end 

				local matches = 	P.ahoc.responses:match_all(val)

				-- get all the responses in   
				for k,pos in pairs( matches ) do 
					local pos_end  = val:find("\r\n",pos,true)
					a[#a+1] = val:sub(pos+1,pos_end-1)
				end
				
				-- log everything 
				P.outfile:write(os.date("%c ",timestamp))
				P.outfile:write(flow:ipa_readable())
				P.outfile:write(" ")
				P.outfile:write(flow:ipz_readable())
				P.outfile:write(" ")
				for i,v in ipairs(a) do
					P.outfile:write(v)
					P.outfile:write(" ")
				end
				P.outfile:write("\n")

				P.outfile:flush();


			else

				-- request, save it 
				
				local a = { } 

				local matches = 	P.ahoc.requests:match_all(val)

				-- get all the requests in 
				for k,pos in pairs( matches ) do 
					local pos_end  = val:find("\r\n",pos,true)
					a[#a+1] = val:sub(pos+1,pos_end-1)
				end

				q:pushlast(a) 

			end
			
		 end

    end,

  },


}
