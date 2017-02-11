--
-- ftp.lua 
--
-- FTP file reassembly 
-- Listens to FTP Traffic and extracts to /tmp/ftpfiles directory
-- 
-- How it works 
-- 1. Script instances listening on FTP-Control (port-21) broadcast  info about Ports and Filenames
-- 2. Script instances use onmessage(..) to maintain a globally consistent map ports->filenames
-- 3. Use OnPayload(..) to save payloads to file 
-- 4. Use OnTerminate(..) to update filenames in case the mapping becomes available mid-way 
-- 
--
-- local dbg=require'debugger'

TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "FTP filex",
    description = "Saves files transferred via FTP into /tmp/ftpfiles",
  },

  onload = function()

    T.ftpendpts  = { }        -- known FTP servers to aggressively start reass o
    T.pending  = { }          -- table containing controlport, dataport, filename mappings 
    T.flowfilenames   = { }   -- dataport to filename 
    T.running_count = 1       -- used to construct unique filename

    os.execute("mkdir -p /tmp/ftpfiles")
  end, 

  -- any messages you want to handle for state management 
  message_subscriptions = {},

  -- WHEN CALLED: when another plugin sends you a message 
  -- onmessage() - all instances of ftp.lua will update their state using this broadcast mechanism 
  -- 
  onmessage = function(msgid, msg)
    print(T.contextid.." MSG "..msg) 
    if msg:match("PORT") then
      local sess,keypart  = msg:match( "FTP PORT (%g+) (%g+)")
      if not T.pending[sess] then T.pending[sess] = {}; end 
      local svrends = T.pending[sess] 
      for _,v in pairs(svrends) do
          if v.endpoint==keypart then return; end 
      end
      svrends[#svrends+1] = { endpoint = keypart, filename = "XuntitledX"} 
    elseif msg:match("CTRL") then 
      local ip2 = msg:match("_([%x%.]+):")
      T.ftpendpts[ip2] = 1
    elseif msg:match("TERM") then 
      local sess = msg:match("FTP TERM (%g+)")
      T.pending[sess] = nil 
      T.flowfilenames[sess] = nil 
    elseif msg:match("NEXT") then
      local sess,fn  = msg:match( "FTP NEXT (%g+) ([%g ]+)")
      local svrends = T.pending[sess] 
      if svrends then 
        svrends[#svrends].filename = fn
        fn = fn:gsub("[^%w%.]","_") -- normalize the file name , only alnum allowed for security
        T.running_count = T.running_count + 1 
      end 
    end 
  end,


  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- enable reassembly for 
    -- 1. if server if a known FTP server, 2. ftp-control 
    -- 
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
    -- if filename is not available yet (latency of broadcast mechanism)
    -- then use XuntitledX as the filename and check again when flow terminates
    -- 
    lookup_filename    = function(flowkey)
      local fn  = T.flowfilenames[flowkey:id()] 
      if fn  then 
        return fn 
      else 
        -- search T.pending  and set the cs 
        local svrpart = flowkey:id():sub(24)
        local svrpart2 = flowkey:id():sub(5,22)
        for _,svrends in pairs(T.pending) do 
          for _,v in pairs(svrends) do 
            print("enpt = "..v.endpoint.. " fn="..v.filename.." ask="..flowkey:id())
            if svrpart == v.endpoint or svrpart2 == v.endpoint then
              local path = "/tmp/ftpfiles/"..T.contextid.."_"..T.running_count.."_"..v.filename
              T.flowfilenames[flowkey:id()] = path
              return path
            end
          end
        end
        if svrpart:match("p-0014") then
          local path = "/tmp/ftpfiles/"..T.contextid.."_"..T.running_count.."_XuntitledX_ftpdata"
          T.flowfilenames[flowkey:id()] = path
        end
      end 
    end,
        

    -- WHEN CALLED: when a chunk of reassembled payload is available 
    -- 
    -- payload on control FTP : extract protocol messages and post_message(..)
    -- payload on data FTP    : lookup filename and write to file 
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
      -- Everything boils down to these  3 lines !! 
      local pfn  = TrisulPlugin.reassembly_handler.lookup_filename(flowkey)
        if pfn then
            -- print(flowkey:id().." WRITING FILE "..pfn.." seekpos="..seekpos) 
            buffer:writetofile( pfn, seekpos) 
        end

      end 
    end,

    -- to cleanup lookup tables,  you can also use a time out mechanism for entries (its just lua!!) 
    -- 
    onterminateflow  = function(engine, timestamp, flowkey) 
      -- Check if you have a new filename available !
      local Plugin = TrisulPlugin.reassembly_handler;
      local oldfn = Plugin.lookup_filename(flowkey)
      if oldfn and oldfn:match("XuntitledX") then
        T.flowfilenames[flowkey:id()]=nil
        local newfn = Plugin.lookup_filename(flowkey)
        if not newfn:match("XuntitledX") then
          os.execute("mv "..oldfn.." "..newfn);
        end
      end
      engine:post_message_frontend("FTP TERM "..flowkey:id())
    end,
  },
}
