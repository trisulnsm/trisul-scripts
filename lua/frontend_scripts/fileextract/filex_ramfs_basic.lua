-- filex_basic_ramfs.lua 
--
--  Basics of File Extraction in Trisul Network Analytics 
--
--  Demonstrates 
--  ------------
--  1. Use of filter(..) to only save text/html content 
--
--  2. When a new file is ready in ramfs- Trisul calls  onfile_http(..). In this
--     script we just print and explore the parameters  
--
--  3. The files do not leave ramfs. To see the files set the 
--     Reassembly>FileExtraction>AutoDelete to 'false' in trisulProbeConfig.xml 
--
--  4. To see the files go do the Ramfs directory typically in 
--     /usr/local/var/lib/trisul-probe/domain0/probeX/contextY/run/ramfs 
--
TrisulPlugin = {

  id = {
    name = "file extraction basics  ",
    description = "various aspects of file extraction ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },



  onload = function()
    print("LOADED : filex1.lua ")
  end,

  onunload = function()
    print("BYE: filex1.lua ")
  end,

  -- 
  -- Monitor attaches itself to file extraction module(s)
  -- gets called at various stages, can control and add stats etc
  --
  filex_monitor  = {

    -- 
    -- filter : decide if you want to reassemble this file or not.. 
    --          return true, if you want this type, false if not 
    --
    filter = function( engine,  timestamp, flowkey, header)

        if header:is_response() then 
            local ct = header:get_value("Content-Type")
            if ct and ct == "text/html" then
                print("KEEPING TEXT HTML with flowkey = "..flowkey:ipa_readable() )
                return true
            else
                return false
            end
        end
        return true
    end,

  -- 
  -- called when the file is completed and stored in 'path' 
  --
  onfile_http = function( engine, timestamp, flowkey, path, req_header, resp_header, length, is_chunk)

    -- print the path where the file is stored on the tmpfs 
    --
    print("length="..length);

    -- run the linux file command - to detect the type of file 
    -- demonstrates how you can operate on the file  justlike normal files 
    os.execute('file '..path);

    -- demonstrates accessing Content-Type (in the HTTP response header)
    --  
    print("content type ="..resp_header:get_value(1));
    print("http status="..resp_header:get_status());

    local cl = resp_header:get_value("Content-Length");
    local te = resp_header:get_value("Transfer-Encoding");


    -- demonstrates printing all the headers 
    -- HTTP request 
    local req_hdrs = req_header:get_all_headers();
    print(" REQUEST HEADERS----")
    for k,v in pairs(req_hdrs) do 
        print(" "..k.." = "..v)
    end

    -- demonstrates printing all the headers 
    -- HTTP response  
    local resp_hdrs = resp_header:get_all_headers();
    print(" \n\nRESPONSE HEADERS----")
    for k,v in pairs(resp_hdrs) do 
        print(" "..k.." = "..v)
    end

    
    -- FINALLY ! Does not do anything with the file itself (in path)
    -- You can copy that file from ramfs onto a persistent file system
    -- in this script we dont do anything, so the file will be deleted 
    -- automatically once all scripts have had a chance to get onfile_http(..)
    -- To keep the file set the Reassembly>FileExtraction>AutoDelete to false
    -- (use that only for debugging, because that could fill up the ramfs) 
    --

    end,

 }

}

