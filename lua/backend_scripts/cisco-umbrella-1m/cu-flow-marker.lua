--
-- cisco-umbrella-flow-marker.lua 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Uses the list + DNS updates to mark flows 
-- DESCRIPTION: Cisco Umbrella list of Top 1M domains is available here 
--              http://s3-us-west-1.amazonaws.com/umbrella-static/index.html 
--        We use this list to check all Flows as being inside or outside
--          then we use a Flow Tagger to mark flows that are outside this list 
--              as "LONGTAIL". 
--        
--        * The companion script cu-dns-extractor.lua broadcasts Name->IP 
--          state updates. 
--        * This script listens to those messages and builds a table T.iplookup
--        * Loads the Top1M domains into a LUA table (approx 90MB RAM reqd) 
--        * Each flow is checked against these two lists. Any outside flows 
--          are marked "NOTCISCOTOP1M" 
--
--        1. sg_monitor       - loads this top 1M  set as LUA table 
--        2. sg_monitor       - uses DNS to maintain IP->Domain table
--        3. sg_monitor       - translates flow IP to domain then checks 1M list
--        4. sg_monitor       - tags outside flows with "LONGTAIL"
-- 
local JSON=require'JSON'
local TOP1MFILE='/tmp/top-1m.csv'
local dbg=require'debugger'
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "Top1M Flow Marker ",
    description = "Marks flows outside Cisco Umbrella 1M ", 
  },


  -- onload : load the 1M file 
  onload=function()
    T.iplookup = { } 
    T.top1m = { } 

    -- load the top 1M 
    T.log("Loading Top 1M Domains from Cisco Umbrella Feed from file ".. TOP1MFILE)

    local f = io.open(TOP1MFILE,"r")
    for l in f:lines() do 
      local h = l:match("%d+,(%S+)")
      T.top1m[h] = true
    end 

    T.log("Finished Loading Top 1M domains from ".. TOP1MFILE)
    T.log("Memory used = "..collectgarbage("count")*1024)

  end,


  -- companion script (DNS extractor) will send this message 
  message_subscriptions = {
    "{796E668C-EA7E-4D98-3826-E15089A2200B}"
  },


  -- update state with new DNS information 
  onmessage = function(msgid, msg)
    local st_update = JSON:decode(msg)

    for _,v in ipairs(st_update.ips) do
      print("Updateing IP "..v.. " name = "..st_update.name) 
      T.iplookup[v] = st_update.name
    end

  end,


  -- sg_monitor   block 
  --
  sg_monitor    = {

    -- got a new flow, examine end point IP for matches 
    -- tag flows as NOTTOP1M if not in Top 1M endpts 
    onnewflow = function(engine, f )

      local ipa = f:flow():ipa_readable();
      local ipz = f:flow():ipz_readable();

      local namea = T.iplookup[ipa]
      local namez = T.iplookup[ipz]

      local intop1m = false  

      --    dbg() 

      intop1m = intop1m or namea and not  T.host:is_homenet(ipa) and T.top1m[namea] 
      intop1m = intop1m or namez and not  T.host:is_homenet(ipz) and T.top1m[namez] 

      if not intop1m then 
        -- outside top 1m - tag this flow 
        print("Tagging flow outside top 1m"..f:flow():to_s()  );
        engine:tag_flow(f:flow():id(), "NOTCISCOTOP1M")
      end 

    end
  }
}
