-- httplog.lua
--
-- A customizable HTTP logger, correlates requests and responses 
-- 
--

require("queue")

TrisulPlugin = {

  id = {
    name = "HTTP Logger ",
    description = "Log req/resp in one line ",
    author = "Unleash", version_major = 1,
    version_minor = 0,
  },



  onload = function () 

    P = TrisulPlugin

	  P.regex = {

	  	requests = {
		  	T.re2("(.*)HTTP/1.\\d\r\n"),
		  	T.re2("Host\\s*:\\s*(.*)\r\n"),
			  T.re2("User-Agent\\s*:\\s*(.*)\r\n"),
			  T.re2("Referer\\s*:\\s*(.*)\r\n")
		  },

      responses = {
        T.re2("HTTP/1.\\d\\s*(.*)\r\n"),
        T.re2("Server\\s*:\\s*(.*)\r\n"),
        T.re2("Content-Type\\s*:\\s*(.*)\r\n"),
        T.re2("Content-Length\\s*:\\s*(.*)\r\n"),
		  }

    }

    P.flowmap = { } 
    math.randomseed(os.time());
    P.outfile = io.open("/tmp/httpheaders-"..math.random(1000,2000)..".log","w")
  end,


  onunload = function()

  	P.outfile:close()

  end,


  flowmonitor  = {

  	onflowattribute = function(engine,flow,timestamp,
							   nm, valobj)

	    if nm == "HTTP-Header" then

        local val = valobj:tostring() 
        local flowkey = flow:id()
        P.flowmap[flowkey] = P.flowmap[flowkey] or queue.new()
        local q = P.flowmap[flowkey]

        if val:find("^HTTP/") then

          local a =  q:popfirst()

          if a then

            -- response 
            for i,v in ipairs( P.regex.responses) do 
              local status, match = v:partial_match_c1(val)
              if status then a[#a+1] = match end
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
          end
          

        else

          local a = { } 

          -- request 
          for i,v in ipairs( P.regex.requests) do 
            local status, match = v:partial_match_c1(val)
            if status then a[i] = match end
          end

          q:pushlast(a) 

        end

		  end

    end,

  },

}
