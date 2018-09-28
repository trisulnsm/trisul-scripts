--
-- ssh_counters
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     For SSH monitor
-- DESCRIPTION: POC of SSH client and server print 
-- 
TrisulPlugin = { 

  id =  {
    name = "SSH hashes - Hassh",
  },

  countergroup = {

    control = {
      guid = "{E49AA7D0-3DC8-46AC-E278-5DD07B298F0A}", 
      name = "HaSSH Prints",
      description = "HaSSH Prints",
      bucketsize = 60,
    },

    -- meters table
    -- id, type of meter, toppers to track, Name, units, units-short 
    -- 
    meters = {
        {  0, T.K.vartype.COUNTER,      20, 20, "SSH Client Types",  "Client Hits",  "hits" },
        {  1, T.K.vartype.COUNTER,      20, 20, "SSH Server Types",  "Server Hits",  "hits" },
    },  
  }
}
