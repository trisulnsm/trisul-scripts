--
-- c2-x509-fts.lua
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Full text search documents streaming
-- DESCRIPTION: Fun script to C2 Channel that transfers chunks of data using a 
--              X509 certificate extension "Subject Key Identifier"
--              Writes each chunk to file in streaming manner 
-- 

-- helper : to write the Hex to binary file chunk 
function string.hex2bin(str)
  return (str:gsub('..', function (cc)
    return string.char(tonumber(cc, 16))
  end))
end

TrisulPlugin = { 

  -- id block
  -- 
  id =  {
    name = "C2-X509 FTS demo",
    description = "pull out C2 binariy",
  },

  onload  = function() 
    T.count = 0;
  end,

  -- pull out large SubjectKeyIdentifier into "chunk files" 
  fts_monitor  = {

    -- 9E.. refers to SSL Certs FTS (you can get this from Trisul UI)
    fts_guid = '{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}',


    -- WHEN CALLED : a new FTS Document is seen
    onnewfts  = function(engine, fts )

      local _,_,ski = fts:text():find("X509v3 Subject Key Identifier:%s*(%S+)") 
      if ski and ski:len() > 32 then 
        T.count = T.count + 1
        local hexski = ski:gsub("[:%s]","")
        local outf = io.open("/tmp/c2ski-"..engine:instanceid().."-"..T.count,"w")
        outf:write(hexski:hex2bin())
        outf:close()
      end 

    end,
  },
}


