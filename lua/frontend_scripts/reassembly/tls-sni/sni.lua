--
-- sni.lua
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Client Hello fingerprint IOC experimental 
-- DESCRIPTION: Trying out https://github.com/salesforce/ja3
-- 
-- Meter HTTPS based on Server Name Indication 
-- 	 new counter group  + resource group 

-- plugin ; reassembly_handler + resource_group  + counter_group
local PDURecord=require'pdurecord' 
local TLSSNI=require'sni-tls'

TrisulPlugin = { 

  id =  {
    name = "SNI monitoring",
    description = "TLS Server Name Indicator extension based metrics",
  },

  -- a new SNI resource 
  -- 
  resourcegroup  = {

    control = {
      guid = "{258DEBA6-B40D-4306-A5DA-DE194064DA7D}",
      name = "SNI",
      description = "SNI Resource IP<->SNI",
    },

  },

  -- a new counter group 
  countergroup = {

    control = {
      guid = "{38497403-23FB-4206-65C2-0AD5C419DD53}",
      name = "SNI",
      description = "Traffic by Server Name Indicator",
      bucketsize = 30,
    },

    -- meters table
    -- id, type of meter, toppers to track, Name, units, units-short 
    -- 
    meters = {
        {  0, T.K.vartype.RATE_COUNTER, 50, "bytes", "Total Traffic",    "Bps" },
        {  1, T.K.vartype.COUNTER,      50, "flows", "Flows",     "Flows" },
    },  


  },

  onload = function()
  	T.Pimpl={}
  end,
 
  -- reassembly_handler block - only on Port-443
  -- 
  reassembly_handler   = {

	onnewflow = function(engine, timestsamp, flowkey)
	  if flowkey:id():find("p-01BB") then 
		  T.Pimpl[flowkey:id()] =  PDURecord.new(flowkey:id(), TLSSNI.new(flowkey))
	  end 
	end,

    -- run the PDU streamer , which will callback into the dissector 
	-- we only worry about OUT direction (==1)
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

	  if flowkey:id():find("p-01BB") and direction==1 then 
		  local pdur = T.Pimpl[flowkey:id()] 
		  pdur.engine=engine
		  pdur.timestamp=timestamp
		  pdur:push_chunk(seekpos, buffer:tostring())
	  end

    end,

    -- 
    onterminateflow  = function(engine, timestamp, flowkey)
	  -- print("TERM "..flowkey:id())
      T.Pimpl[flowkey:id()]  = nil 
    end,

  },

}
