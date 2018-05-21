--
-- IP2Location : Region state+city 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc City", },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{E85FEB77-942C-411D-DF12-5DFCFCF2B932}",
      name = "IP2Loc City",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER,      10, 0, "Total",          "Bps",  "Bps" },
        {  1, T.K.vartype.RATE_COUNTER,      10, 0, "Upload To",      "Bps",  "Bps" },
        {  2, T.K.vartype.RATE_COUNTER,      10, 0, "Download From",  "Bps",  "Bps" },
    },  

  },
}
