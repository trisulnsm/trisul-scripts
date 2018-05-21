--
-- IP2Location : ASN numbers 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc ASN", },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{EF44F11F-B90B-4B24-A9F5-86482C51D125}",
      name = "IP2Loc ASN",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER,      10, 0, "Total",          "Bps",  "Bps" },
        {  1, T.K.vartype.RATE_COUNTER,      10, 0, "Upload To",      "Bps",  "Bps" },
        {  2, T.K.vartype.RATE_COUNTER,      10, 0, "Download From",  "Bps",  "Bps" },
    },  

  },
}
