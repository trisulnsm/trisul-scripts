--
-- IP2Location : Country code counters 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc Country", description="Country Metrics"},


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{F962527D-985D-42FD-91D5-DA39F4D2A222}",
      name = "IP2Loc Country",
	  description = "Meters Country",
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
