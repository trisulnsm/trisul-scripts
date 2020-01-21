--
-- Counter :  Public Key Algorithms seen 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "TLS Sig Algo",
    description = "Meter cert signature algorithms", -- optional
  },

  -- 
  countergroup = {

    -- control table 
	-- specify details of your new counter group you can use 
	-- 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{C90640F6-ACD1-4BE5-92FF-A417DC6A987A}",
      name = "TLS Sig Algo",
      description = "Counts cert signature algos",
      bucketsize = 30,
    },

    -- meters table
    -- id, type of meter, toppers to track, bottom-ers to track, Name, units, units-short 
    -- 
    meters = {
        {  0, T.K.vartype.COUNTER,      10, 0, "Certs",  "certs",  "Certs" },
    },  
  },
}
