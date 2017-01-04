--
-- Filex Monitor
--
-- 
TrisulPlugin = { 
  id =  {
    name = "Filex Monitor",
    description = "Control file extraction",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  filex_monitor  = {

    -- a fully extracted file in ramfs is available, process it 
    -- 
    -- enable or disable particular flows
    filter_flow = function(engine, timestamp, flowkey) 
      -- your lua code goes here 
    end,

    -- look at http request/resp header and decide if you want content
    filter = function(engine, timestamp, flowkey, header) 
      -- your lua code goes here 
    end,
    
    -- raw bytes as they are reassembled stream here 
    onpayload_raw = function(engine, timestamp, flowkey, direction, seekpos, buffer) 
      -- your lua code goes here 
    end,

    -- http bytes (decompresed and normalized) stream here 
    onpayload_http = function(engine, timestamp, flowkey, path, req_header, resp_header, direction, seekpos, buffer) 
                                                                        -- your lua code goes here 
    end,

    onfile_http = function(ngine, timestamp, flowkey, path, req_header, resp_header, length, is_partial) 
      -- your lua code goes here 
    end,

  },
}