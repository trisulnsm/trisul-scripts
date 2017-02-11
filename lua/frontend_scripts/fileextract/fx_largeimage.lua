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
    print("LOADED : filex_largeimage.lua ")
  end,

  onunload = function()
    print("BYE: filex_largeimage.lua ")
  end,

  -- 
  -- Monitor attaches itself to file extraction module(s)
  -- gets called at various stages, can control and add stats etc
  --
  filex_monitor  = {


    -- 
    -- filter : decide if you want to reassemble this file or not.. 
    --
    filter = function( engine,  timestamp, flowkey, header)
      if header:is_response() or header:is_method("post") then 
        local ct = header:get_value("Content-Type")
        if ct and ct:match("jpeg")   then
            T.log(">>>>>  Saving JPG  file for analysis "..ct) 
            return true
        else
            return false
        end
      else 
        -- request
        -- always return true 
        return true
      end
    end,


    -- save all content to /tmp/kk 
    --
    onfile_http  = function ( engine, timestamp, flowkey, path, req_header, resp_header, length )
      local ct = resp_header:get_value("Content-Type")
      if ct and ct:match("jpeg") and length > 500000   then
         local fn = path:match("^.+/(.+)$")
         if fn then
       T.async:copy( path, "/tmp/filex/largejpg/"..fn)
         end
      end 
    end,

 }

}

