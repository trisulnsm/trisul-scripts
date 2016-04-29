-- .lua
--
-- snmp.lua
-- Hooks on to the 1 minute ontimer() mechanism
-- to query SNMP and feed counters into Trisul 
--

-- // {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}
-- define_guid(<<name>>,
-- 0x9781db2c, 0xf78a, 0x4f7f, 0xa7, 0xe8, 0x2b, 0x1a, 0x9a, 0x7b, 0xe7, 0x1a);

TrisulPlugin = {

  id = {
    name = "SNMP Interface",
    description = "Per Interface Stats : Key Agent:IfIndex ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  countergroup = {
    control = {
      guid = "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
      name = "SNMP-Interface",
      description = "Traffic using SNMP input ",
      bucketsize = 60,
    },

    meters = {
        {  0, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "Total BW",   "Bps" },
        {  1, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "In Octets",  "Bps" },
        {  2, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "Out Octets",  "Bps" },
    },  
  },


}

