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
    -- http payload
    --
    onpayload_http  = function(engine, timestamp, flowkey, direction, seekpos, buffer)
      print("---- Payload DIRECTION "..direction.." LENGTH = "..buffer:size().." OFFSET = "..seekpos)
    end,

    

    -- 
    -- save all content to /tmp/kk 
    --
    onfile_http  = function ( engine, timestamp, flowkey, req_header, resp_header, path , length )
      local fn = path:match("^.+/(.+)$")
      T.async:copy( path, "/tmp/kk/"..fn)
    end,

 }

}

