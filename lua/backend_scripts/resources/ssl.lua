-- ssl.lua
--
-- Sample skeleton script for monitoring resources 

--
-- 


TrisulPlugin = {

  id =  {
    name = "Prints SSL Cert resources ",
    description = "Just prints SSL Certs ",
  },


  resource_monitor   = {

    -- want the SSL 
    resource_guid = function()
      for name ,guid in pairs(T.resourcegroups) do 
        if name:match("SSL") then return guid; end
      end
    end,

    -- a new resource  was seen - print all details to screen 
    onnewresource  = function(engine, newresource )
      print("---------------------------------------------------------------------------------------------")
      print("timestamp "..  os.date('%c',newresource:timestamp()))
      print("certsubject = ".. newresource:uri())
      print("flow  = ".. newresource:flow():to_s())
    end,

  },

}
