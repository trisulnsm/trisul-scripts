--
-- ftp.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     extract FTP files 
-- 
--
--
-- local dbg=require'debugger'
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "FTP filex",
    description = "Save reassembled TCP payloads into separate files for XYZ host",
  },

  onload = function()
    T.ftpendpts  = { } 
    T.pending  = { } 
    T.controlsession   = { } 
    T.running_count = 1 
  end, 

  -- any messages you want to handle for state management 
  message_subscriptions = {},

  -- WHEN CALLED: when another plugin sends you a message 
  onmessage = function(msgid, msg)
    print(T.contextid.." MSG "..msg) 
    if msg:match("PORT") then
        local sess,keypart  = msg:match( "FTP PORT (%g+) (%g+)")
        if not T.pending[sess] then T.pending[sess]={endpoint = "" , filename ="" } end 
        T.pending[sess].endpoint = keypart
    elseif msg:match("CTRL") then 
        local ip2 = msg:match("_([%x%.]+):")
        T.ftpendpts[ip2] = 1
    elseif msg:match("TERM") then 
        local sess = msg:match("FTP TERM (%g+)")
        T.pending[sess] = nil 
        T.controlsession[sess] = nil 
    elseif msg:match("NEXT") then
        local sess,fn  = msg:match( "FTP NEXT (%g+) ([%g ]+)")
        if not T.pending[sess] then T.pending[sess]={filename =""}; end 
        fn = fn:gsub("[^%w%.]","_") -- normalize the file name , only alnum allowed for security
        T.pending[sess].filename = fn 
        T.running_count = T.running_count + 1 
    end 
  end,


  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    --  look at flow tuples and decide if you want to reassemble 
    --  return true : to enable reassembly , false to disable
    --  skip this function if you always want to enable 
    filter = function(engine, timestamp, flowkey) 

    print("FILTER "..flowkey:id())
        if TrisulPlugin.reassembly_handler.known_ftp_server(flowkey) then
            return true
        elseif flowkey:id():match("p-0015")  then 
            engine:post_message_frontend("FTP CTRL "..flowkey:id())
            return true
        else 
            return false
        end
    end,

    -- is this a known FTP server? 
    known_ftp_server = function(flowkey)
        local svrpart1 = flowkey:id():sub(24,34)
        local svrpart2 = flowkey:id():sub(5,15)
        return T.ftpendpts[svrpart1] or T.ftpendpts[svrpart2]
    end, 

    -- filename currently waiting on the control session 
    lookup_filename    = function(flowkey)
        local fn  = T.controlsession[flowkey:id()] 
        if fn  then 
            return fn 
        else 
            -- search T.pending  and set the cs 
            local svrpart = flowkey:id():sub(24)
            local svrpart2 = flowkey:id():sub(5,22)
            for _,v in pairs(T.pending) do 
                if svrpart == v.endpoint or svrpart2 == v.endpoint then
                    T.controlsession[flowkey:id()] = v.filename
                    return v.filename
                end
            end
        end 
    end,
        

    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    -- payload on control FTP : extract protocol messages and post_message(..)
    -- payload on data FTP : lookup filename and write to file 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
        if flowkey:id():match("p-0015") then 
            -- CONTROL CHANNEL messages 
            
            -- passive ftp ; message the data channel to other LUA instances
            local octets = buffer:tostring():match("227 Entering Passive Mode %((.*)%)")
            if octets then
                local ip0,ip1,ip2,ip3,p0,p1 = octets:match("(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)")
                local port = p0 * 256 + p1 
                local endpt   = string.format("%02X.%02X.%02X.%02X:p-%04X", ip0,ip1,ip2,ip3,port)
                engine:post_message_frontend("FTP PORT "..flowkey:id().." "..endpt)
            end

            -- active ftp ; message the FTP-DATA channel to other LUA
            local clientoctets = buffer:tostring():match("PORT%s+([%d,]+)")
            if clientoctets then
                local ip0,ip1,ip2,ip3,p0,p1 = clientoctets:match("(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)")
                local port = p0 * 256 + p1 
                local endpt   = string.format("%02X.%02X.%02X.%02X:p-%04X", ip0,ip1,ip2,ip3,port)
                engine:post_message_frontend("FTP PORT "..flowkey:id().." "..endpt)
            end

            -- file name ; message the filename 
            local retr  = buffer:tostring():match("150 Opening %u+ mode data connection for ([%g]+)") 
            if retr then 
                print("ret = "..retr) 
                engine:post_message_frontend("FTP NEXT "..flowkey:id().." "..retr)
            end
        else
            -- Possibly a data channel , write to file 
            local pfn  = TrisulPlugin.reassembly_handler.lookup_filename(flowkey)
            if pfn then
                local path = "/tmp/"..engine:instanceid().."_"..T.running_count.."_"..pfn
                -- print(flowkey:id().." WRITING FILE "..path.." seekpos="..seekpos) 
                buffer:writetofile( path, seekpos) 
            end

        end 
    end,

    -- to cleanup lookup tables,  you can also use a time out mechanism for entries (its just lua!!) 
    -- 
    onterminateflow  = function(engine, timestamp, flowkey) 
        engine:post_message_frontend("FTP TERM "..flowkey:id())
    end,
  },
}
