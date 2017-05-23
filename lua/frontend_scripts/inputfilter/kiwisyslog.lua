--
--  kiwisyslog.lua
--
--  Type : InputFilter
--
--  Consume Netflow information exported from ARCSIGHT via KIWISYSLOG 
--  This version uses the flowimport helper library (flowimport.lua) 
--
-- the format looks like this 
-- 2017-03-21 11:07:13,Local7.Debug,172.24.21.58,"""srcaddr=7338388383,SysUptime=3693443660,dst_as=00,dstport=80,DevicePort=52435,dstaddr=7338388383,pad1=0,pad2=0,output=1,Last=7338388383,prot=6,DeviceAddress=7338388383tcp_flags=26,dPkts=463,tos=0,First=7338388383,src_as=61999,dst_mask=27,unix_nsecs=0,count=30,src_mask=0,version=05,nexthop=8888888888,dOctets=33355,input=3,engine_type=0,unix_secs=1490079998,engine_id=0,reserved=0,srcport=32173,flow_sequence=1044333853"""

-- local dbg = require("debugger")
local FI=require'flowimport'

TrisulPlugin = {

    id = {
      name = "Netflow from KiwiSYSLOG - 2, using flowimport library ",
      description = "NFSYSLOG2",
    },

    onload = function()
      T.log("Opening input file : "..T.args);
    T.datafilename = T.args

    print("opening ".. T.args)
      datfile = io.open(T.datafilename)
      T.count = 0 
    end,


    onunload = function ()
      T.log("Bye closing");
      datfile:close();
    end,


    inputfilter  = {

      -- nextmetrics
      -- read the next line and update flow metrics 
      step  = function(packet, engine)


        local nextline = datfile:read()

        -- check if end of file, 
        -- then pipeline must shutdown by returning false 
        if nextline == nil or #nextline == 0 then
          return false
        end

		-- read the line into a LUA table using a regex
        if nextline:match("^%s+$") then return true; end 
        local rec = {}
        for a,b in nextline:gmatch("([%w_]+)=(%w+)") do
          rec[a]=b
        end
        if rec.srcaddr  ==nil   then  return true; end 


		-- set fields in table and call helper library to import into Trisul 
        packet:set_timestamp(rec.unix_secs);
		FI.process_flow(engine, {
			first_timestamp=rec.First,
			last_timestamp=rec.Last,
			router_ip= T.util.ntop(rec.DeviceAddress),
			source_ip= T.util.ntop(rec.srcaddr),
			source_port= rec.srcport,
			destination_ip= T.util.ntop(rec.dstaddr),
			destination_port= rec.dstport,
			protocol= rec.prot,
			input_interface=tonumber(rec.input),
			output_interface=tonumber(rec.output),
			bytes=tonumber(rec.dOctets),
			packets=tonumber(rec.dPkts),
		});

		-- progress every 10K records 
        if T.count % 10000==0 then 
          print("Processed "..T.count .. " flows")
        end 
        T.count = T.count + 1


		-- true return, means there is more 
        return true 
            
    end,

  },

}

