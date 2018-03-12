--
-- UA-Browser counter group 
-- 
-- 
TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "UA Browser",
    description = "Browser hits ", -- optional
  },


  -- countergroup block
  -- 
  countergroup = {

    control = {
      guid = "{747F125F-2838-4A76-6D44-55974DE58F78}",
      name = "UA Browser",
      description = "Browser hits based on UA",
      bucketsize = 30,
    },

    -- meters table
    -- id, type of meter, toppers to track, bottom-ers to track, Name, units, units-short 
    -- 
    meters = {
        {  0, T.K.vartype.COUNTER,      10, 10, "Hits",  "hits",  "hits" },
    },  

  },
}
