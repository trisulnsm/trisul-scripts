-- save_content-types.lua --
-- Same as save_content_types.lua with one extra twist 
-- 
-- We also perform a SHA256 hash and feed that back into TRISUL as a 
-- new resource. This helps with correlation with analysis such as 
-- that found on malware-traffic-analysis.net 
-- 
-- Note : removed comments for those concepts already found in save_content_types.lua
--

TrisulPlugin = {

  id = {
    name = "Save Content Types 1",
    description = "How to save based on http content type",
  },


  -- make sure the output directory is present 
  onload = function()
    os.execute("mkdir -p /tmp/savedfiles")
  end,


  -- Table filex_monitor contains functions in this module 
  -- if content-type in response matches that regex.. we want the file  
  filex_monitor  = {
    filter = function( engine,  timestamp, flowkey, header)
      if header:is_request() or 
	     (header:is_response() and header:match_value("Content-Type", 
			                       "(shockwave|msdownload|dosexec|pdf|swf|octet)"))  then 
        return true
      else 
        return false
      end
    end,


    -- save all content to /tmp/savedfiles  
    -- notice we use T.async:copy instead of copying file directly using Linux 'cp'
    -- this is because we are in the fast packet path when executing this method so we
    -- do all I/O out in a separate thread 
    --
    onfile_http  = function ( engine, timestamp, flowkey, path, req_header, resp_header, length )

      -- separate the path (which is in ramfs) from the synthesized file name
      -- 


      T.async:schedule(
          {
              -- send the file path ; need to pack everything into a string
              -- 
              data = path..'|'..flowkey:id()  ,

              --
              -- [ on slow path, another thread ]
              -- calc sha1sum on the file
              -- and return the string
              -- 
              onexecute = function( indata)

			  	local path, flowid = T.util.splitm(indata,'|')

				-- compute the sha256 sum using the linux tool
				-- note that since the extracted file is still 
				-- in ramfs, this will be quite fast 
                local h = io.popen("sha256sum  "..path)
                local sha256  = h:read("*a"):match('%w+') -- sha256sum output <hash> <path> we want the hash 


				-- copy the file over to /tmp/savedfiles
				-- just like we did in save_content_type.lua
				local fn = path:match("^.+/(.+)$")
				os.execute("cp  "..path.."  /tmp/savedfiles/"..fn)

                return sha256.."|"..fn.."|"..flowid
              end,

              --
              -- [ back on fast path]
              -- 
              onresult = function(engine, req, response)

				local hex_sha256, path, flowid = T.util.splitm(response,'|')

                 --  print("The SHA256 sum is   ".. response)
				engine:add_resource('{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}',  -- represents FileHash resource in Trisul 
									flowid,
									"SHA256:"..hex_sha256,
									path)
              end
          }
      )

    end,


 }
}

