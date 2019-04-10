--
-- IP2Location : Proxy 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc Proxy", description="Proxy Metrics"},


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{2DCA13EB-0EB3-46F6-CAA2-9989EA904051}",
      name = "IP2Loc Proxy",
	  description = "Meters Proxy",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER,      40, 40, "Total",          "Total",    "Bps" },
        {  1, T.K.vartype.RATE_COUNTER,      40, 40, "Upload To",      "Upload To",   "Bps" },
        {  2, T.K.vartype.RATE_COUNTER,      40, 40, "Download From",  "Download From", "Bps" },
        {  3, T.K.vartype.COUNTER,      	 40, 40, "Flows",  		   "Flows", "flows" },
    },  

  },
}
