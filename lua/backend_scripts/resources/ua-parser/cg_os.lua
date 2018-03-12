--
-- UA-OS counter group 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "UA OS",
    description = "Browser hits ", -- optional
  },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{0F67F47E-A407-4047-2AF6-8E25FEC75C3A}",
      name = "UA OS",
      description = "OS hits based on UA",
      bucketsize = 30,
    },

    meters = {
        {  0, T.K.vartype.COUNTER,      10, 10, "Hits",  "hits",  "hits" },
    },  

  },
}
