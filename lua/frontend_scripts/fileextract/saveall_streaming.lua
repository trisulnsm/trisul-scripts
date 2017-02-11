-- .lua
--
-- filex
--  Save all but use the OnPayload(..) streaming interface 
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
    print("LOADED : fx_video.lua  ")
  end,

  onunload = function()
    print("BYE: fx_video.lua ")
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
        if ct and ct:match("video")   then
          print(">>>>>  Saving video file for analysis "..ct.."flow - "..flowkey:id() ) 
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
    onfile_http  = function ( engine, timestamp, flowkey, path, req_header, resp_header, length , partial_flag )

      local ct = resp_header:get_value("Content-Type")
      if ct and ct:match("video")   then
        if partial_flag then 
          local fn = path:match("^.+/(.+)%.%d+.part$")
          print(">>>>>  PARTIAL VIDEO AsyncCat ."..fn)
          --  just a chunk , concatenate with prev 
          --
          T.async:cat( path, "/tmp/filex/video/"..fn)

        else
          -- full file 
          --
          local fn = path:match("^.+/(.+)$")

          T.async:copy( path, "/tmp/filex/video/"..fn)

        end 
      end
    end,

  }

}

