--
-- IP2Location : Country code counters 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc Country", },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{F962527D-985D-42FD-91D5-DA39F4D2A222}",
      name = "IP2Loc Country",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER,      10, 0, "Total",          "Bps",  "Bps" },
        {  1, T.K.vartype.RATE_COUNTER,      10, 0, "Upload To",      "Bps",  "Bps" },
        {  2, T.K.vartype.RATE_COUNTER,      10, 0, "Download From",  "Bps",  "Bps" },
    },  

  },
}
