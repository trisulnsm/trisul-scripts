-- re2http.lua
--
-- Use RE2 regex to capture select HTTP headers and log them
-- 
-- Demonstrates 
--   1. Use re2:partial_match_cN(..) , match with capture 
--
TrisulPlugin = {

  id = {
    name = "HTTP Parse Sample",
    description = "Use REGEX re2 to parse ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },



  onload = function () 

    P = TrisulPlugin

	-- 
	-- we log the date, user-agent, host, referrer
	--
	P.regexes   =  {
		T.re2("User-Agent\\s*:\\s*(.*)\r\n"),
		T.re2("Host\\s*:\\s*(.*)\r\n"),
		T.re2("Referer\\s*:\\s*(.*)\r\n")
	}
  math.randomseed(os.time())


	P.outfile = io.open("/tmp/httpheaders-"..math.random(1000,2000)..".log","w")

  end,


  onunload = function()

  	P.outfile.close()

  end,


  flowmonitor  = {

	onflowattribute = function(engine,flow,timestamp,
							   attribute_name, attribute_value)

	     if attribute_name == "HTTP-Header" then

			local val = attribute_value:tostring() 

			--
			-- write to output 
			--
			P.outfile:write(os.date("%c",timestamp))
			P.outfile:write("\t")
			for i,v in ipairs( P.regexes) do 
				local status, match = v:partial_match_c1(val)
				if status then
					P.outfile:write(match)
					P.outfile:write("\t")
				end
			end
			P.outfile:write("\n")

		 end

    end,

  },

}

