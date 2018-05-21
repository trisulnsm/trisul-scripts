--
-- IP2Location : Proxy 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc Proxy", },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{2DCA13EB-0EB3-46F6-CAA2-9989EA904051}",
      name = "IP2Loc Proxy",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER,      10, 0, "Total",          "Bps",  "Bps" },
        {  1, T.K.vartype.RATE_COUNTER,      10, 0, "Upload To",      "Bps",  "Bps" },
        {  2, T.K.vartype.RATE_COUNTER,      10, 0, "Download From",  "Bps",  "Bps" },
    },  

  },
}
