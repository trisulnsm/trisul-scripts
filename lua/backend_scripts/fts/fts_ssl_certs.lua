--
-- fts_ssl_certs.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Full text search documents streaming
-- DESCRIPTION: Check the leaf ssl cert with issuer ssl cert using OCSP
--              
-- 
TrisulPlugin = { 
  

  -- id block
  -- 
  id =  {
    name = "HTTP Header Monitor",
    description = "Monitor your fts HTTP Headers and do xyz",
    author = "Unleash",                       -- optional
    version_major = 1,                        -- optional
    version_minor = 0,                        -- optional
  },



  onload = function()
  end,

  onunload = function()
  end,


  --
  fts_monitor  = {

    -- which FTS group do you want to monitor
    fts_guid = '{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}',

    -- WHEN CALLED : a new FTS Document is seen
    onnewfts  = function(engine, fts )
      local cert = os.tmpname().."_leaf.cert"
      local issuer = os.tmpname().."_issuer.cert"
      print(fts:text():match("X509:(.*=)(.*)X509:(.*=)"))
    end,


  },
}
