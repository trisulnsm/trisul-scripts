-- ac-httplog.lua
--
-- HTTP Logger , this time using Aho-Corasik T.ac(..) 
-- 
--
--
--

local dbg= require ("debugger")
require ("queue")



TrisulPlugin = {

  id = {
    name = "HTTP Logger ",
    description = "Log req/resp in one line ",
    author = "Unleash", version_major = 1,
    version_minor = 0,
	clsid= "{ff2faa88-57bb-42b7-af27-edda7c91a437}",
  },



  onload = function () 

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

	dbg()

	print("Container ID = "..T.host:id());

	local fn="/tmp/httpheaders-"..T.host:id(); 
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

		 	if val:find("^HTTP/") then

				local q = P.flowmap[flowkey]

				if not q  then print("Q not found"); return; end 

				local a =  q:popfirst()


				if not a then return; end 

				print("FOUND")

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


				P.update_flowmap( flowkey, val);

				local bcastmsg = flowkey.."\t"..val ;
				T.host:broadcast( "{00000000-0000-0000-0000-000000000001}",TrisulPlugin.id.clsid,  bcastmsg  )

			end
			
		 end

    end,

  },

  channellistener  = {

	onchannelmessage = function(msgid, databuf )

		-- request, save it 
		local sp  = T.util.split( databuf:tostring(), "\t");
		local flowkey,val  = sp[1],sp[2];
		P.update_flowmap( flowkey, val);

	end , 

  },

  update_flowmap = function( flowkey, httpheader )

	local matches = 	P.ahoc.requests:match_all(httpheader)

	local a = { } 

	-- get all the requests in 
	for k,pos in pairs( matches ) do 
		local pos_end  = httpheader:find("\r\n",pos,true)
		a[#a+1] = httpheader:sub(pos+1,pos_end-1)
	end

	P.flowmap[flowkey] = P.flowmap[flowkey] or queue.new()
	local q = P.flowmap[flowkey]
	q:pushlast(a) 

  end,


}
