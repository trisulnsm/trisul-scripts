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
  T.dbg = require("debugger")

  end,

  onunload = function()
  end,


  --
  fts_monitor  = {

    -- which FTS group do you want to monitor
    fts_guid = '{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}',

    -- WHEN CALLED : a new FTS Document is seen
    onnewfts  = function(engine, fts )
      local leaf_cert_file = os.tmpname()
      local issuer_cert_file = os.tmpname()
      local cert0,cert1 = fts:text():match("X509:(.*).*%-%-%-.*X509:(-*).*%-%-%-.*")
      cert0 = cert0:gsub("^\n",""):gsub("\n$","")
      cert1 = cert1:gsub("^\n",""):gsub("\n$","")

      local tmp_pem = io.open(leaf_cert_file,"w")
      tmp_pem:write("-----BEGIN CERTIFICATE-----\n")
      tmp_pem:write(cert0);
      tmp_pem:write("-----END CERTIFICATE-----\n")
      tmp_pem:close()

      local tmp_pem1 = io.open(issuer_cert_file,"w")
      tmp_pem1:write("-----BEGIN CERTIFICATE-----\n")
      tmp_pem1:write(cert1);
      tmp_pem1:write("-----END CERTIFICATE-----\n")
      tmp_pem1:close()
      --print ("openssl ocsp -issuer  "..issuer_cert_file.." -cert "..leaf_cert_file.." -url http://ocsp.digicert.com")
      local ocsp = io.popen("openssl ocsp -issuer  "..issuer_cert_file.." -cert "..leaf_cert_file.." -url http://ocsp.digicert.com")
      print(ocsp:read("*a"))
      os.remove(leaf_cert_file)
      os.remove(issuer_cert_file)
    end,


  },
}
