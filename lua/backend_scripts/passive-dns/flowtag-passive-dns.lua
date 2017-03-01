-- flow-tag
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Tags flows with domain name. 
-- DESCRIPTION: Using a real time passive DNS database , we tag flows as they are flushed 
--          with the domain name. Top level for COM, ORG, NET and 3 level for othersj
--
--        This script does the following
--        1. leveldb      - uses LUAJIT FFI to build a LEVELDB backend 
--              2. fts monitor      - listens to DNS and updates the ldb  CNAME/A
-- 
--

local leveldb=require'tris_leveldb'
TrisulPlugin = {

  id =  {
    name = "pDNS tagger",
    description = "Passive DNS Flow Tagger ",
  },

  -- we listen to onmessage for pDNS attach event
  message_subscriptions = { '{4349BFA4-536C-4310-C25E-E7C997B92244}' },

  onmessage=function(msgid, msg)
  local dbaddr = msg:match("newleveldb=(%S+)")
  _,T.LevelReader = leveldb.from_addr(dbaddr);
  end,

  -- session_group : flow monitor
  -- as flows as flushed we tag em 
  sg_monitor  = {

  --
  -- for each IP we look up the pDNS and add the tag 
  -- 
    onflush = function(engine,flw)

      if T.LevelReader==nil then return; end 

      local ipa = flw:flow():ipa_readable()
      local ipz = flw:flow():ipz_readable()

      local p1 = T.LevelReader( ipa)
      local p2 = T.LevelReader( ipz)

      if p1 then 
        local last_two = p1:match('(%w+%.%a+)$')
        -- print("Adding tag for "..ipa.." = "..last_two)
        flw:add_tag( last_two)
      end

      if p2 then 
        local last_two = p2:match('(%w+%.%a+)$')
        -- print("Adding tag for "..ipz.." = "..last_two)
        flw:add_tag( last_two)
      end

    end,


  },

}
