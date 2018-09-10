-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "Protocol Tree",
    description = "protocol tree", 
  },

  -- countergroup block
  -- 
  countergroup = {

    -- control table 
    control = {
      guid = "{2CF4DCFF-77E5-45E9-AA03-8D827CE0813C}", 
      name = "Protocol Tree",
      description = "Protocol tree based counting like MAWI",
      bucketsize = 60,
    },

    -- meters table
    meters = {
        {  0, T.K.vartype.COUNTER,      20, 10, "Bytes",    "pkts",  "Pkts" },
        {  1, T.K.vartype.COUNTER,      20, 10, "Packets",  "pkts",  "Pkts" },
    },  
  },
}
