--
-- filex_monitor.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Handle HTTP based file extraction 
-- DESCRIPTION: Hook into Trisul's file extraction engine. 
--              High level: *need* a RAMFS (tmpfs) filesystem to which Trisul will write 
--              file chunks and call your lua. You can then copy the file to a normal FS.
--        Low level: Streaming interface to extraction using onpayload_xx(..) 
-- 
-- 
TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "Filex Monitor",
    description = "Control file extraction", -- optional
    author = "Unleash", -- optional
    version_major = 1, -- optional
    version_minor = 0, -- optional
  },

  -- COMMON FUNCTIONS:  onload, onunload, onmessage 
  -- 
  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
    -- your code 
  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    -- your code 
  end,

  -- any messages you want to handle for state management 
  message_subscriptions = {},

  -- WHEN CALLED: when another plugin sends you a message 
  onmessage = function(msgid, msg)
    
  end,


  -- filex_monitor block
  -- 
  filex_monitor  = {

    -- WHEN CALLED:  a new flow is detected 
    --   enable return true, or false disable this flow
    --   usage: Use this to suppress file extraction for specific IP, ports etc 
    filter_flow = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
      return true 
    end,



    -- WHEN CALLED: a new HTTP header is seen 
    --    look at http request/resp header and decide if you want content
    --    return true; want to extract content pertaining to this header 
    --    return false; skip the content related to this header 
    -- 
    filter = function(engine, timestamp, flowkey, header) 
      -- your lua code goes here 
      return true
    end,
    

    -- WHEN CALLED: a raw payload chunk is ready
    --  this is before HTTP normalization (dechunk, and unzip) 
    onpayload_raw = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: a HTTP chunk is available 
    --  this is after  HTTP normalization (dechunk, and unzip) 
    --  you could just save this to get the actual content in streaming mode 
    onpayload_http = function(engine, timestamp, flowkey, path, req_header, resp_header, direction, seekpos, buffer) 
      -- your lua code goes here 
    end,



    -- WHEN CALLED: a reassmbled file is ready in ramfs partition
    -- a fully extracted file in ramfs is available in 'path' , process it 
    onfile_http = function(ngine, timestamp, flowkey, path, req_header, resp_header, length, is_partial) 
      -- your lua code goes here 
    end,

  },
}
