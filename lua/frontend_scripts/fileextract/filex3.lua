-- .lua
--
-- filex
--  File Extraction by lua 
--
--
TrisulPlugin = {

  id = {
    name = "file extraction  ",
    description = "various aspects of file extraction ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },



  onload = function()
    print("LOADED : filex.lua ")
  end,

  onunload = function()
    print("BYE: filex.lua ")
  end,

  -- 
  -- Monitor attaches itself to file extraction module(s)
  -- gets called at various stages, can control and add stats etc
  --
  filex_monitor  = {

    -- 
    -- filter_flow : you want this flow at all? 
    --  true : yes. extract this flow
    --  no   : skip this flow 
    -- 
    filter_flow  = function( engine,  timestamp, flowkey)
      return true
    end,



    -- 
    -- filter : decide if you want to reassemble this file or not.. 
    --
    filter = function( engine,  timestamp, flowkey, header)
      print("LUA FILTER  ");
      return true
    end,


    -- 
    -- save all content to /tmp/kk 
    --
    onfile_http  = function ( engine, timestamp, flowkey, req_header, resp_header, path , length )

      local fn = path:match("^.+/(.+)$")

      print("LUA filename ="..fn);
      print("LUA length="..length);

      local ct = resp_header:get_value("content-type")
      if ct and ct:match("image") then 
        T.async:copy( path, "/tmp/kk/"..fn)
      end 

      if path:match("tab_left.gif") then 
        engine:disable_reassembly(flowkey:id())
      end 


    end,

 }

}

