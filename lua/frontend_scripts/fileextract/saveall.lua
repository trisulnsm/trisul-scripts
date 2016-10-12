-- .lua
--
-- saveall(.)
--  Saves all files into /tmp/trisul_files , even the large ones that arrive in chunks
--
--
TrisulPlugin = {

  id = {
    name = "saveall files",
    description = "saves all files into /tmp/fx_files",
    author = "Unleash", version_major = 1, version_minor = 0,
  },



  onload = function()
  	os.execute("mkdir -p /tmp/trisul_files")
  end,

  -- 
  -- Save everything from the ramfs to /tmp/.. 
  -- the 'is_chunk' is used to handle large files which are presented to this 
  -- script in large (5MB or 10MB) chunks (see trisulProbeConfig.xml)
  --
  filex_monitor  = {


    -- save all content to /tmp/kk 
    --
    onfile_http  = function ( engine, timestamp, flowkey, path, req_header, resp_header, length , is_chunk )

		if is_chunk then 
		   local fn = path:match("^.+/(.+)%.%d+.part$")
		   --  just a chunk , concatenate with prev 
		   --
		   T.async:cat( path, "/tmp/trisul_files/"..fn)

		else
		   -- full file 
		   --
		   local fn = path:match("^.+/(.+)$")

		   T.async:copy( path, "/tmp/trisul_files/"..fn)

		end 

    end,

 }

}

