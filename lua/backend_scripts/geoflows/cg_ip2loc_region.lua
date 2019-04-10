--
-- IP2Location : Region state+city 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc City", description="City metrics"},


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{E85FEB77-942C-411D-DF12-5DFCFCF2B932}",
      name = "IP2Loc City",
	  description = "Meters city",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.RATE_COUNTER,      40, 40, "Total",          "Total",         "Bps" },
        {  1, T.K.vartype.RATE_COUNTER,      40, 40, "Upload To",      "Upload To",     "Bps" },
        {  2, T.K.vartype.RATE_COUNTER,      40, 40, "Download From",  "Download From", "Bps" },
        {  3, T.K.vartype.COUNTER,      	 40, 40, "Flows",  		   "Flows",         "flows" },
    },  

  },
}
