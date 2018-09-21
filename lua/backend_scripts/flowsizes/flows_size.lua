-- flows sizes vs volume distribution 
-- 
TrisulPlugin = { 

  id =  {
    name = "Flowsizes",
    description = "flow size analytics", -- optional
  },


  sg_monitor  = {

    onflush = function(engine, flow) 
      -- packet size into  log10 range  
      local totalbytes = flow:az_bytes()  + flow:za_bytes() 
      if totalbytes > 0 then 
        local key =  tostring(math.ceil( math.log10(totalbytes))) .. " Dig"
        engine:update_counter( "{91D08D08-B846-4C28-1FC9-A2C419DCC605}", key, 0, 1)
        engine:update_counter( "{91D08D08-B846-4C28-1FC9-A2C419DCC605}", key, 1, totalbytes)
      end 
    end,
  },


  countergroup = {

    control = {
      guid = "{91D08D08-B846-4C28-1FC9-A2C419DCC605}",
      name = "Flow Sizes",
      description = "Flow sizes distribution",
      bucketsize = 60,
    },

    -- meters table
    meters = {
      {  0, T.K.vartype.COUNTER,      50, 30, "Flows",  "flows",  "Flws" },
      {  1, T.K.vartype.COUNTER,      50, 30, "Bytes",  "bytes",  "Bytes" },
    },  
  },
}

