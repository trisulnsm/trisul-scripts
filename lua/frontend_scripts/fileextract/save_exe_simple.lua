-- save_exe.lua
--
-- Saves all Executable files using the magic number method
-- into /tmp/savedfiles
-- 
-- The regex we are using is (shockwave|msdownload|dosexec|pdf) to save common malware files
-- SWF,PDF,MSI,EXE etc
--
--
TrisulPlugin = {

  id = {
    name = "Save EXE",
    description = "Extract MSI,EXE, use magic numbers",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  -- make sure the output directory is present 
  onload = function()
    os.execute("mkdir -p /tmp/savedfiles")
	T.trigger_patterns = T.re2("(?i)(msdos|ms-dos|microsoft|windows|elf|executable|pdf|flash)")
	T.savechunks={}
  end,

  -- Table filex_monitor contains functions in this module 
  filex_monitor  = {


    -- save all content to /tmp/savedfiles  
	-- then check magic number using `file ..` if it matches microsoft pull it out 
    --
    onfile_http  = function ( engine, timestamp, flow, path, req_header, resp_header, length , is_chunk )

      -- you can get 0 length for HTTP 304, etc - skip it (or log it in other ways etc)
      if length == 0 then return; end 

	  -- get magic number 
	  local h = io.popen("file -b "..path)
	  local val = h:read("*a")
	  h:close()

	  -- 
	  if T.trigger_patterns:partial_match(val) then 
		  T.savechunks[flow:id()]=true 
	  elseif not is_chunk then 
		  T.savechunks[flow:id()]=false 
	  end 
	  	

	  -- does this trigger our RE2 pattern 
	  if T.savechunks[flow:id()]  then 

		  if is_chunk then 
			   local fn,off = path:match("^.+/(.+)%.%d+.part$")
			   --  just a chunk , concatenate with prev 
			   --
			   T.async:cat( path, "/tmp/savedfiles/"..fn)
		  else
			   -- full file 
			   --
			   local fn = path:match("^.+/(.+)$")
			   T.async:copy( path, "/tmp/savedfiles/"..fn)
		  end 

	  end 

	end,


	-- flow terminated ; clean up 
	onterminateflow = function(engine, ts, flow)
		T.savechunks[flow:id()]=nil 
	end,
 }
}

