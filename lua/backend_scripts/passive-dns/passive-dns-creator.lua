--
-- passive-dns-creator.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Creates a real time PASSIVE DNS database 
-- DESCRIPTION: A passive DNS database observes DNS traffic and builds a IP->name
--        and name->IP lookup over time. For NSM purposes an IP->Name mapping is 
--        a crucial capability for real time streaming analytics. 
--
--        This script does the following
--        1. leveldb      - uses LUAJIT FFI to build a LEVELDB backend 
--              2. fts monitor      - listens to DNS and updates the ldb  CNAME/A
-- 
local leveldb=require'tris_leveldb'

TrisulPlugin = { 

  id =  {
    name = "Passive DNS",
    description = "Listens to DNS traffic and builds a IP->Name passive DNS database", 
  },

  onmessage=function(msgid, msg)
    if msgid=='{4349BFA4-536C-4310-C25E-E7C997B92244}' then
      local dbaddr = msg:match("newleveldb=(%S+)")
      T.LevelWriter,_,T.LevelCloser = leveldb.from_addr(dbaddr);
    end
  end,


  -- open the LevelDB database  & create the reader/writer 
  onload = function() 
    T.pending,T.owner=false,false
  end,


  -- close 
  onunload = function()
    if T.owner then 
      print("Closing Leveldb from owner")
      T.LevelCloser()
    end 
  end, 


  -- fts_monitor  block 
  --
  fts_monitor   = {

    -- DNS FTS - ensure <CreateFTSDocument> is enabled in config file 
    fts_guid = '{09B305DF-078C-4B9E-8E2F-EA64B7326880}',

    -- WHEN CALLED : a new fts doc  is seen (within 1sec)
    -- the regex here picks out the QUESTION NAME and all the IP in the A records
    -- use print(fts:text()) to see the actual record, or use the WebTrisul UI 
    --
    onnewfts  = function(engine, fts )

      if T.LevelWriter == nil then 
        if engine:instanceid() == "0" and not T.pending then
          local dbfile = T.env.get_config("App>DBRoot").."/config/PassiveDNSDB.level";
          T.dbaddr = leveldb.open(dbfile); -- dont use local to prevent GC 
          T.pending = true
          T.owner=true
          engine:post_message_backend('{4349BFA4-536C-4310-C25E-E7C997B92244}', "newleveldb="..T.dbaddr) 
        end
        return
      end

      local doc = fts:text()
      if doc:match("^RESPONSE") then

        local q = doc:match("Questions%s*%.([%.%w%-]*)%s*A%s*IN")
        if not q then return; end 

        local a = doc:gmatch("A%s*IN%s*([%d%.]+)")

        for s in a do 
          print("Engine:".. engine:instanceid().." Saved "..s.." => "..q)
          T.LevelWriter(s,q)
        end 

      end 
    end,

  }

}
