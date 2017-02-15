-- sha256_x509.lua
--
-- Goal here is - we want to get the SHA256 finger print of the TLS Certificate
-- resource stream.  
-- 
-- 1. if you print the resource note that the SHA1 fingerprint is already computed
--    by the Trisul native SSL processing (print the URI field) see print_resource.lua 
--
-- 2. SHA256 is computed by taking out the raw certifcates in BER , then turning it into
--    BER and then running the linux sha256sum over it 
-- 
-- Demonstrates 
-- 1. How to save the certificates to filesystem
-- 2. Feed back the new SHA256 certificate hash into Trisul resources pipelines 
--  

-- local dbg=require'debugger'

TrisulPlugin = {

  id =  {
    name = "Prints File Hashes seen ",
    description = "Sample script that just prints new file hashes as they are seen ",
  },

  onload=function()
    os.execute('mkdir -p /tmp/saved_certs')
  end,


  resource_monitor   = {

      resource_guid = '{5AEE3F0B-9304-44BE-BBD0-0467052CF468}',

    onnewresource  = function(engine, newresource )

      -- demo showing that SHA1 finger print is already calculated by Trisul
      -- we use the match(..) to get the top cert in chain 
      local sha1print  = newresource:uri():match("SHA1:(%w+)")




      -- step 1: save the cert to a PEM file ( BASE64 ) 
      --
      local pem_file  = os.tmpname()
      local der_file  = os.tmpname() 

      local tmp_pem = io.open(pem_file,"w")
      tmp_pem:write("-----BEGIN CERTIFICATE-----\n")
      tmp_pem:write(newresource:label());
      tmp_pem:write("-----END CERTIFICATE-----\n")
      tmp_pem:close()


      -- step 2: openssl to DER file 
      --
      os.execute("openssl x509  -in "..pem_file.." -outform der -out ".. der_file) 

      -- step 3 : sha256sum on the DER file 
      local pipeout  = io.popen("sha256sum "..der_file)
      local sha256sum = pipeout:read("*a")
      pipeout:close()

      print("Cert sha256 fingerprint "..sha256sum:match("%w+"))
      -- dbg()

      -- feed the SHA256 sum back into Trisul as a new type of resource 
      engine:add_resource('{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}',  -- represents FileHash resource in Trisul 
                newresource:flow():id(),
                "CERTSHA256:"..sha256sum:match("%w+"),
                "")


      os.remove(pem_file)
      os.remove(der_file)
    end,
  }
  
}
