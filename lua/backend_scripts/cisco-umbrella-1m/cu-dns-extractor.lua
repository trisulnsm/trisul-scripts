--
-- cisco-umbrella-dns-extractor.lua 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Use Cisco Umbrella Top 1M to mark flows 
-- DESCRIPTION: Cisco Umbrella list of Top 1M domains is available here 
--              http://s3-us-west-1.amazonaws.com/umbrella-static/index.html 
--				We use this list to check all Flows as being inside or outside
--			    then we use a Flow Tagger to mark flows that are outside this list 
--              as "LONGTAIL". 
--				
--              This script listens to DNS FTS Document Stream , extracts 
--                 name -> IP mapping, then broadcasts this state update. 
--				The companion script cisco-umbrella-flow-marker.lua builds
-- 				   a database of IP->name and loads the 1M list. Each flow
--                 is checked against these lists. 
--			    The goal is to tag Flows outside this top list, you can then search
--                 using that tag.
--
--				1. fts monitor      - listens to DNS and broadcasts CNAME/A
-- 
local JSON=require'JSON'

TrisulPlugin = { 

  id =  {
    name = "DNS Resource Monitor",
    description = "DNS resources are hostname IP mapping stream ", 
  },



  -- fts_monitor  block 
  --
  fts_monitor   = {

	-- DNS FTS - ensure <CreateFTSDocument> is enabled in config file 
    fts_guid = '{09B305DF-078C-4B9E-8E2F-EA64B7326880}',

    -- WHEN CALLED : a new fts doc  is seen (immediately)
	-- the regex here picks out the QUESTION NAME and all the IP in the A records
	-- use print(fts:text()) to see the actual record, or use the WebTrisul UI 
    onnewfts  = function(engine, fts )
		local doc = fts:text()
		if doc:match("^RESPONSE") then

			local q = doc:match("Questions%s*%.([%.%w%-]*)%s*A%s*IN")
			if not q then return; end 

			local a = doc:gmatch("A%s*IN%s*([%d%.]+)")
			local msg = {
				name = q,
				ips = {}
			};
			for s in a do msg.ips[#msg.ips+1]=s; end 

			-- state update message , the companion script cu-flow-marker.lua listens to this msgid 
			engine:post_message_backend("{796E668C-EA7E-4D98-3826-E15089A2200B}", JSON:encode(msg))
		end 
    end,

  }

}
