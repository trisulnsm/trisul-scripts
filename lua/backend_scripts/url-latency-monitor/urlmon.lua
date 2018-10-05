--
-- URL-Monitor
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Response Time per Service 
-- DESCRIPTION: for HTTP
-- 
TrisulPlugin = { 

  -- id block
  --
  id =  {
    name = "URL Mon",
    description = "URL Response Time", 
  },

  -- resource_monitor block 
  --
  resource_monitor  = {

    resource_guid = '{4EF9DEB9-4332-4867-A667-6A30C5900E9E}', 

    -- add
    onnewresource  = function(engine, resource )
		local res = resource:uri()
		local l,k,v = res:match("(%S+)%s(%S+)%s([^%?%s]+)")
		local usec = resource:label():match("usec:(%d+)")

		if usec then
			local key = l.."/"..k..v
			local latency = tonumber(usec)
			engine:update_counter( "{C93B79D5-20A0-49D8-FA27-160B45D49C00}", key, 0, 1);
			engine:update_counter( "{C93B79D5-20A0-49D8-FA27-160B45D49C00}", key, 1, latency);
			engine:update_counter( "{C93B79D5-20A0-49D8-FA27-160B45D49C00}", key, 2, latency);
			engine:update_counter( "{C93B79D5-20A0-49D8-FA27-160B45D49C00}", key, 3, latency);

			print(key.."="..latency)
		end 
    end,

  },

  countergroup = {

    control = {
      guid = "{C93B79D5-20A0-49D8-FA27-160B45D49C00}", 
      name = "URL Service ",
      description = "URL Service Response Times ",
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
