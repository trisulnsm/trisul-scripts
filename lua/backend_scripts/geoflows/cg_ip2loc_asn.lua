--
-- IP2Location : ASN numbers 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  { name = "IP2Loc ASN", description ="ASN metrics"},


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{EF44F11F-B90B-4B24-A9F5-86482C51D125}",
      name = "IP2Loc ASN",
	  description = "Meters ASN",
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
