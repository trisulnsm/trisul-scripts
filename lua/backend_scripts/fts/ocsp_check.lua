-- ocsp_print.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Full text search documents streaming
-- DESCRIPTION: Check the leaf ssl cert with issuer ssl cert using OCSP
--              this just prints the results INLINE 
--				use this to play with the framework. The full version of this 
-- 				script is ocsp_check_async.lua in this dir. 

local dbg=require'debugger'

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
 ifts_monitor  = {

    -- which FTS group do you want to monitor
    fts_guid = '{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}',

    -- WHEN CALLED : a new FTS Document is seen
    onnewfts  = function(engine, fts )


    local certchain = {} 
    for cert in fts:text():gmatch("%-*BEGIN CERTIFICATE.-END CERTIFICATE%-*")  do 
      certchain[#certchain+1]=cert
    end

    local ocspservers = {}

    for ocspsvr  in fts:text():gmatch("OCSP %- URI:(%S+)") do
      ocspservers[#ocspservers+1] = ocspsvr
      print(ocspsvr)
    end

      local subject_pem  = "/tmp/subject_"..engine:id()..".pem"
      local sp,err  = io.open(subject_pem,"w")
      sp:write(certchain[1]);
      sp:close()

      local issuer_pem = "/tmp/issuer_"..engine:id()..".pem"
      local ip , err = io.open(issuer_pem,"w")
      ip:write(certchain[2]);
      ip:close()

      local ocsp = io.popen("openssl ocsp -noverify -issuer  "..issuer_pem..
                   " -cert "..subject_pem.." -url ".. ocspservers[1]..
                   " -header 'HOST' ".."'"..ocspservers[1]:match('http://(%S+)').."'" )
      print(ocsp:read("*a"))

      -- dbg() 

      os.remove(subject_pem)
      os.remove(issuer_pem)
    end,


  },
}
