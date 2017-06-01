--
-- skip_youtube.lua
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Fine grained control of PCAP storage
-- DESCRIPTION: Dont store packets from youtube,googlevideo,twitter,netflix 
--
-- 1. plug into a passiveDNS DB 
-- 2. when new flow is setup; check if IP maps to youtube/googlevideo/twitter use a pre compiledregex
-- 3. block matches, allow others 
-- 
-- Requires the PassiveDNS Lua plugin that extracts IP->Domain and broadcasts to all filters
-- 
local leveldb=require'tris_leveldb' 

TrisulPlugin = { 

  id =  {
    name = "SKIP PCAP(YT)",
    description = "Skip youtube,twitter,netflix ", 
  },

  -- pre-Compile the regex 
  onload = function()
    T.re2x = T.re2("(youtube|googlevideo|twitter|ytimg|twimg|netflix|nflxvideo|nflximg|nflxext)")
    T.LevelReader = nil 
  end,


  -- we listen to onmessage for a pDNS attach event
  -- this requires passive_dns.lua script 
  message_subscriptions = { '{4349BFA4-536C-4310-C25E-E7C997B92244}' },
  onmessage=function(msgid, msg)
    local dbaddr = msg:match("newleveldb=(%S+)")
    _,T.LevelReader = leveldb.from_addr(dbaddr);

    print(T.contextid.. "  Got Broadcast from ".. msg)
  end,


  -- packet_storage block
  -- lookup IPZ (usually the outside IP) -> domain name
  -- use the Regex to filter the domain name 
  packet_storage   = {

    filter = function( engine, timestamp, flow ) 

        if T.LevelReader then 

            local name =  T.LevelReader( flow:ipz_readable());
            if name then 
                local ok, category = T.re2x:partial_match_c1( name)
                if ok then 
                    print( T.contextid .. " skip flow=" .. flow:to_s() .. "   map=" .. category) 
                    return 0
                end 
            end
        end
        return -1 
    end

  },
}
