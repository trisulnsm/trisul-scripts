-- saveall_2.lua
--
-- Save ALL HTTP payloads seen 
-- Method2 - uses the T.async method copy instead of using the full blown 
--           async interface 
--
TrisulPlugin = {

  id = {
    name = "saveall",
    description = "save all files to a directory ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },



  -- ensure present 
  onload = function()
    os.execute("mkdir -p /tmp/kk")
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
      T.async:copy( path, "/tmp/kk/"..fn)
    end,

 }

}

