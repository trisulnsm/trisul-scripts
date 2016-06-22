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
  	print("LOADED : filex_dm.lua ")
  end,

  onunload = function()
  	print("BYE: filex_dm.lua ")
  end,

  -- 
  -- Monitor attaches itself to file extraction module(s)
  -- gets called at various stages, can control and add stats etc
  --
  filex_monitor  = {


    -- save all content to /tmp/kk 
    --
    onfile_http  = function ( engine, timestamp, flowkey, path, req_header, resp_header, length )
       local fn = path:match("^.+/(.+)$")
       if fn then
           T.async:execute( 
                {
                    data = "cp "..path.."  /tmp/kk3/"..fn,

                    onexecute = function( indata) 
						require "os";
						os.execute(indata)
                    end,

                    oncomplete = function( indata, outdata)

                    end,
                }
           )
       end
    end,

 }

}

