-- .lua
--
-- filex_stream 
-- File Extraction by lua  using the onpayload(..) streaming interface
-- this script operates on buffers, just appends them  to a file
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
  	os.execute('mkdir -p /tmp/kk')
  end,



  filex_monitor  = {

    -- save all content to /tmp/kk 
    --
    onpayload_http   = function ( engine, timestamp, flowkey, path, req_header, resp_header, dir , seekpos , buffer )

	
	    local fn = path:match("^.+/(.+)$")
	    T.async:copybuffer( buffer, "/tmp/kk/"..fn)

    end,

 }

}
