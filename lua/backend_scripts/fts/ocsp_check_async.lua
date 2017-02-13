--
-- fts_ssl_certs.lua skeleton
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Full text search documents streaming
-- DESCRIPTION: Check the leaf ssl cert with issuer ssl cert using OCSP
--              
-- 

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
  	T.count = 0

  end,

  onunload = function()
  end,


  --
  fts_monitor  = {

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

	  T.count = T.count + 1

      local subject_pem  = "/tmp/subject_"..engine:id().."-"..T.count..".pem"
      local sp,err  = io.open(subject_pem,"w")
      sp:write(certchain[1]);
      sp:close()

      local issuer_pem = "/tmp/issuer_"..engine:id().."-"..T.count..".pem"
      local ip , err = io.open(issuer_pem,"w")
      ip:write(certchain[2]);
      ip:close()


      local ocsp_cmd  = "openssl ocsp -noverify -issuer  "..issuer_pem..
	  						   " -cert "..subject_pem.." -url ".. ocspservers[1]..
							   	 " -header 'HOST' ".."'"..ocspservers[1]:match('http://(%S+)').."'" ;

		T.async:schedule(
		  {
			  -- the data  
			  data = ocsp_cmd,

			  -- [ on slow path, another thread ]
			  onexecute = function( openssl_cmd )
				  local resp = io.popen( openssl_cmd)

				  print(resp:read("*a"))

				  local subject_pem = openssl_cmd:match("cert%s+(%S)")
				  local issuer_pem = openssl_cmd:match("issuer%s+(%S)")

		
				  os.remove(issuer_pem)
				  os.remove(subject_pem)


				  local success = resp:match('good')
				  if not success  then 
				  	return resp
				  end
			  end,

			  -- [ back on fast path]
			  onresult = function(engine, req, response)
				  
			  end
		  }
		)


    end,


  },
}
