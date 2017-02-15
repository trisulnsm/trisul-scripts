-- ocsp_check_async.lua 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Check a cert chain using OSCP 
-- DESCRIPTION: Listen to FTS (Full Text Search) SSL Cert stream extract subject and issuer certs
--              then use standard 'openssl ocsp ..' command to check. Generate a Trisul Alert
--              if any cert fails the test.
--              
--              Note: This version uses the T.async execution method because the network lookup may
--              be slow. Strictly speaking for low volume networks you can do this inline because 
--              'fts_monitor' is a backend_script hence not in the high speed packet path. 
-- 

-- local dbg=require'debugger'
local JSON=require'JSON'

TrisulPlugin = { 
  

  -- id block
  -- 
  id =  {
    name = "OCSP checker",
    description = "Use openssl ocsp to verify top cert",
  },


  onload = function()
    T.count = 0
    T.checked_hashes  = {} 
  end,

  onunload = function()
  end,

  --
  fts_monitor  = {

    -- which FTS group do you want to monitor
    fts_guid = '{9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}',

    -- WHEN CALLED : a new FTS Document is seen
    onnewfts  = function(engine, fts )

      -- 
      -- extract individual certificates from the chain. 
      -- the FTS object is a text object in well known openssl format (check fts:text() )
      -- or go to FTS > SSL Certs in the Trisul UI 
      -- 
      local certchain = {} 
      for cert in fts:text():gmatch("%-*BEGIN CERTIFICATE.-END CERTIFICATE%-*")  do 
        certchain[#certchain+1]=cert
      end

      -- check if chain 1 & 2 have been recently checked  in past 1 hr
      local hash = T.util.hash( certchain[1] .. certchain[2] )
      if T.checked_hashes[hash]  then 
            if  fts:timestamp() - T.checked_hashes[hash] < 3600 then
                -- ignore just checked same cert 1hrs ago
                return
            end
      end
      T.checked_hashes[hash] = fts:timestamp() 

      -- extract the OCSP server list 
      local ocspservers = {}
      for ocspsvr  in fts:text():gmatch("OCSP %- URI:(%S+)") do
        ocspservers[#ocspservers+1] = ocspsvr
        print(ocspsvr)
      end

      -- if no OCSP option alert !
      if #ocspservers == 0  then
        engine:add_alert( 
                "{5E97C3A3-41DB-4E34-92C3-87C904FAB83E}", -- GUID for Badfellas 
                fts:flow():id(), 
                "NO-OCSP",  -- a sigid (private range)
                1,
                "Cant find OCSP Authority Information Acccess element in certificate ")
      end 

      -- count for generating unique names for input cert files
      T.count = T.count + 1

      -- dump the cert 
      local subject_pem  = "/tmp/subject_"..engine:id().."-"..T.count..".pem"
      local sp,err  = io.open(subject_pem,"w")
      sp:write(certchain[1]);
      sp:close()

      -- dump the issuer 
      local issuer_pem = "/tmp/issuer_"..engine:id().."-"..T.count..".pem"
      local ip , err = io.open(issuer_pem,"w")
      ip:write(certchain[2]);
      ip:close()

      -- the command you want to run asyns (due to network I/O)  
      local ocsp_cmd  = "openssl ocsp -noverify -issuer  "..issuer_pem..
                               " -cert "..subject_pem.." -url ".. ocspservers[1]..
                                 " -header 'HOST' ".."'"..ocspservers[1]:match('http://([%w%.]+)').."'" ;

      -- schedule an ASYNC execution 
      -- the schedule(..) method returns immediately
      -- the execution and onresult call back wil happen at some later time (dont worry when but soon enough)
        T.async:schedule(
          {
              -- the data  
              data = JSON:encode { 
                run_cmd = ocsp_cmd,
                flow_id =  fts:flow():id(),
                timestamp = fts:timestamp(),
                cert_file = subject_pem,
                issuer_file = issuer_pem
              }, 


              -- [ on slow path, another thread ]
              onexecute = function( json_cmd  )
                  -- we need this because the outside JSON is not an upvalue, 
                  -- visible inside the ASYNC context
                  local JSON=require'JSON'

                  -- unpack the command 
                  local work_item = JSON:decode(  json_cmd) 

                  -- run cmd 
                  local pipein = io.popen( work_item.run_cmd)
                  resp= pipein:read("*a")

                  os.remove(work_item.issuer_file)
                  os.remove(work_item.cert_file)

                  if not resp:match('good') then 
                    local alert_data = JSON:encode( { 
                        flow_id = work_item.flow_id,
                        resp_text = resp,
                    });
                    return alert_data;
                  end

                  -- return nothing or nil means we have nothing more to do
                  -- return a string, means onresult(..) will be called with that string 

              end,

              -- [ back on fast path]
              onresult = function(engine, req, response)
                local JSON=require'JSON'
                print("OCSP CHECK FAILED. Generating alert")
                local alert_item = JSON:decode(response)
                engine:add_alert( 
                        "{5E97C3A3-41DB-4E34-92C3-87C904FAB83E}", -- GUID for Badfellas 
                        alert_item.flow_id, 
                        "OCSP-FAILED",                            -- a sigid (private range)
                        1,
                        "OCSP verification failed resp="..alert_item.resp_text)
              end
          }
        )
    end,
  },
}
