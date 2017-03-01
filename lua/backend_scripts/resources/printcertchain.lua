-- dumpcerts.lua
--
-- Print cert chains 
-- 

TrisulPlugin = {

  id =  {
    name = "Prints SSL Cert resources ",
    description = "Just prints SSL Certs ",
  },


  resource_monitor   = {

    -- want the SSL 
    resource_guid = '{5AEE3F0B-9304-44BE-BBD0-0467052CF468}',

    -- a new resource  was seen - print all details to screen 
    onnewresource  = function(engine, newresource )

    for cert in newresource:label():gmatch("%-*BEGIN CERTIFICATE.-END CERTIFICATE%-*")  do 
      print(cert)
    end

    end,

  },

}
