--
-- UA-Device counter group 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "UA Device",
  },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{EB232F1A-05E6-45E7-1888-9AF224511E6D}",
      name = "UA Device",
      description = "Device hits based on UA",
      bucketsize = 30,
    },

    meters = {
        {  0, T.K.vartype.COUNTER,      10, 0, "Hits",  "hits",  "hits" },
    },  

  },
}
