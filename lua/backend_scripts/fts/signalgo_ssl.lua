--
-- signalgo.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Alert on WEAK signature algoritms used in SSL Certs 
-- DESCRIPTION: Inspired by latest release of Google Chrome which blocks access to SSL sites
--              that use sha1 
-- 
-- how this script works :  listens to SSL Certs FTS stream and parses the documents using Regex
-- 
-- local dbg=require'debugger'

TrisulPlugin = { 

  id =  {
    name = "Sign Algo monitor",
    description = "Alert on sign algo ",
  },

  fts_monitor  = {

    fts_guid = function()  
		return T.ftsgroups['SSL Certs']
	end, 

	-- listen to the SSL Certs document stream 
    onnewfts  = function(engine, fts )

		local certchain = fts:text()

		if certchain:find("sha1With") then 
			local alertmsg = "seen a sha1 cert ------".."\n"

			-- use regex to pull out the subject, issuer,etc 
			for m,n,o in certchain:gmatch("NAME:([%S% ]+)\n.-Issuer: ([%S% ]+)\n.-Signature Algorithm: (%S+)") do
				alertmsg = alertmsg .. m .. "\n"
				alertmsg = alertmsg .. "  ".. n.. "\n"
				alertmsg = alertmsg .. "     ".. o.. "\n"
			end
			alertmsg = alertmsg .. "---------".. "\n"

			T.log("Found a sha1 cert in flow id "..fts:flow():id() .."  adding an alert")
			engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}"  , -- {B51.. = user alerts 
							fts:flow():id(),
							"SSLSHA1",
							2,
							alertmsg);
							

		end 
    end,

  },
}
