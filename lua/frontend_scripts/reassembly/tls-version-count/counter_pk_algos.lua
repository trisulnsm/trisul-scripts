--
-- Counter :  Public Key Algorithms seen 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "TLS Public Key Algo",
    description = "Meter cert public key algorithms", -- optional
  },

  -- 
  countergroup = {

    -- control table 
	-- specify details of your new counter group you can use 
	-- 'trisulctl_probe testbench guid' to get a new GUID
    control = {
      guid = "{88F603AE-4519-4E3D-E1C8-D1882E398724}",
      name = "TLS Public Key Algo",
      description = "Counts cert pk algos",
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
