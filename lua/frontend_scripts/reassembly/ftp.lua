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
        T.pending[sess].filename = ""
    elseif msg:match("CTRL") then 
        local ip2 = msg:match("_([%x%.]+):")
        T.ftpendpts[ip2] = 1
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

        if TrisulPlugin.reassembly_handler.known_ftp_server(flowkey) then
            return true
        elseif flowkey:id():match("p-0015")  then 
            engine:post_message_frontend("FTP CTRL "..flowkey:id())
            return true
        else 
            return false
        end

    end,

    known_ftp_server = function(flowkey)
        local svrpart1 = flowkey:id():sub(24,34)
        local svrpart2 = flowkey:id():sub(5,15)
        return T.ftpendpts[svrpart1] or T.ftpendpts[svrpart2]
    end, 

    lookup_control_session   = function(flowkey)
        local cs = T.controlsession[flowkey:id()] 
        if cs  then 
            return cs
        else 
            -- search T.pending  and set the cs 
            local svrpart = flowkey:id():sub(24)
            local svrpart2 = flowkey:id():sub(5,22)
            for k,v in pairs(T.pending) do 
                if svrpart == v.endpoint or svrpart2 == v.endpoint then
                    T.controlsession[flowkey:id()] = k 
                    return k
                end
            end
        end 
    end,
        

    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    -- handle reassembled byte stream here , 
    -- 
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
        if flowkey:id():match("p-0015") then 
            local octets = buffer:tostring():match("227 Entering Passive Mode %((.*)%)")
            if octets then
                local ip0,ip1,ip2,ip3,p0,p1 = octets:match("(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)")
                local port = p0 * 256 + p1 
                local endpt   = string.format("%02X.%02X.%02X.%02X:p-%04X", ip0,ip1,ip2,ip3,port)
                engine:post_message_frontend("FTP PORT "..flowkey:id().." "..endpt)
            end

            local retr  = buffer:tostring():match("150 Opening %u+ mode data connection for ([%g]+)") 
            if retr then 
                print("ret = "..retr) 
                engine:post_message_frontend("FTP NEXT "..flowkey:id().." "..retr)
            end
        else
            local cs  = TrisulPlugin.reassembly_handler.lookup_control_session(flowkey)
            if cs then 
            local pfn = T.pending[cs]
                if pfn.filename  then
                    local path = "/tmp/"..engine:instanceid().."_"..T.running_count.."_"..pfn.filename
                    print(flowkey:id().." WRITING FILE "..path.." seekpos="..seekpos) 
                    buffer:writetofile( path, seekpos) 
                end
            end 

        end 
    end,

    -- WHEN CALLED: a flow is terminated or timed out 
    -- 
    onterminateflow  = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,


  },

}
