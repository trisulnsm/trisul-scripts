--
-- Counter Group API Latency
--
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "API Latency",
    description = "API Latency", 
  },

  countergroup = {

    control = {
      guid = "{9497A90C-86DF-44A5-439F-3B4092792728}",
      name = "API Latency",
      description = "API Response Times",
	  bucketsize = 10,
    },

    -- meters table
    -- id, type of meter, toppers to track, Name, units, units-short 
    -- 
    meters = {
        {  0, T.K.vartype.COUNTER,      20,20,  "Hits",  "Hits",    "hits" },
        {  1, T.K.vartype.AVERAGE,      20,20,  "Avg",   "Avg_us",  "us" },
        {  2, T.K.vartype.MAXIMUM,      20,20,  "Max",   "Max_us",  "us" },
        {  3, T.K.vartype.MINIMUM,      20,20,  "Min",   "Min_us",  "us" },
    },  

  }

}
