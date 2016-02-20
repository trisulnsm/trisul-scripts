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
    T.end_of_flow_content = 0;
  end,

  onunload = function()
  	print("BYE: filex.lua ")

    print(" WE FOUND ENDOF COTENT TYPE OBJECTS COUNT = ".. T.end_of_flow_content)
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
    onfile_http2  = function ( engine, timestamp, flowkey, req_header, resp_header, path , length )

        print("KYA LUA path="..path);
        print("KYA length="..length);

        os.execute('file '..path);

        print("KYA content type ="..resp_header:get_value("Content-Type"));

        local cl = resp_header:get_value("Content-Length");
        local te = resp_header:get_value("Transfer-Encoding");

        if (cl == nil and te == nil) then 
            T.end_of_flow_content = T.end_of_flow_content +1 
        end 


        local req_hdrs = req_header:get_all_headers();
        print(" REQUEST HEADERS----")
        for k,v in pairs(req_hdrs) do 
            print(" "..k.." = "..v)
        end

        local resp_hdrs = resp_header:get_all_headers();
        print(" \n\nRESPONSE HEADERS----")
        for k,v in pairs(resp_hdrs) do 
            print(" "..k.." = "..v)
        end



    end,

 }

}

