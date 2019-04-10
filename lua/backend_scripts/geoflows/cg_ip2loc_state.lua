--
-- IP2Location : State 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc State", description="State within country metrics"},


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{5C28445E-19E3-499E-E14D-E4CC7128B62B}",
      name = "IP2Loc State",
	  description = "Meters state",
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
