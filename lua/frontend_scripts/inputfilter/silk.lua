--
--  silk.lua 
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
local ffi=require'ffi'

-- 
-- SiLK format taken from file rwrec.h 
-- Sorry ! We only support IPv4 as of now 
--
ffi.cdef[[


struct rwGenericRec_V5_st {
    int64_t         sTime;       /*  0- 7  Flow start time in milliseconds
                                  *        since UNIX epoch */

    uint32_t        elapsed;     /*  8-11  Duration of flow in millisecs */

    uint16_t        sPort;       /* 12-13  Source port */
    uint16_t        dPort;       /* 14-15  Destination port */

    uint8_t         proto;       /* 16     IP protocol */
    uint8_t  		flow_type;  /* 17     Class & Type info */
    uint16_t  		sID;         /* 18-19  Sensor ID */

    uint8_t         flags;       /* 20     OR of all flags (Netflow flags) */
    uint8_t         init_flags;  /* 21     TCP flags in first packet
                                  *        or blank for "legacy" data */
    uint8_t         rest_flags;  /* 22     TCP flags on non-initial packet
                                  *        or blank for "legacy" data */
    uint8_t         tcp_state;   /* 23     TCP state machine info (below) */

    uint16_t        application; /* 24-25  "Service" port set by collector */
    uint16_t        memo;        /* 26-27  Application specific field */

    uint16_t        input;       /* 28-29  Router incoming SNMP interface */
    uint16_t        output;      /* 30-31  Router outgoing SNMP interface */

    uint32_t        pkts;        /* 32-35  Count of packets */
    uint32_t        bytes;       /* 36-39  Count of bytes */

    uint32_t     	sIP;         /* 40-43  (or 40-55 if IPv6) Source IP */
    uint32_t     	dIP;         /* 44-47  (or 56-71 if IPv6) Destination IP */
    uint32_t     	nhIP;        /* 48-51  (or 72-87 if IPv6) Routr NextHop IP*/
};

]] 


TrisulPlugin = {

    id = {
      name = "Netflow from KiwiSYSLOG - 2, using flowimport library ",
      description = "NFSYSLOG2",
    },

    onload = function()
      T.log("Opening input file : "..T.args);
      T.datafilename = T.args
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

	  	if T.count==0 then
			local ignoreheader = datfile:read(52)
		end
		T.count = T.count+1


        local nextline = datfile:read(52)
		if nextline == nil then return false; end 

		local cCast = ffi.cast("struct rwGenericRec_V5_st *", nextline)
		local stime = tonumber(cCast.sTime)/1000
		local ltime=stime+tonumber(cCast.elapsed)/1000

		-- set fields in table and call helper library to import into Trisul 
        packet:set_timestamp(stime)
		FI.process_flow(engine, {
			first_timestamp=stime,
			last_timestamp=stime+tonumber(cCast.elapsed)/1000,
			router_ip= T.util.ntop(cCast.sID),
			source_ip= T.util.ntop(cCast.sIP),
			source_port= cCast.sPort,
			destination_ip= T.util.ntop(cCast.dIP),
			destination_port= cCast.dPort,
			protocol= cCast.proto,
			input_interface=tonumber(cCast.input),
			output_interface=tonumber(cCast.output),
			bytes=tonumber(cCast.bytes),
			packets=tonumber(cCast.pkts),
		});
		local jjj =  {
			first_timestamp=stime,
			last_timestamp=stime+tonumber(cCast.elapsed)/1000,
			router_ip= T.util.ntop(cCast.sID),
			source_ip= T.util.ntop(cCast.sIP),
			source_port= cCast.sPort,
			destination_ip= T.util.ntop(cCast.dIP),
			destination_port= cCast.dPort,
			protocol= cCast.proto,
			input_interface=tonumber(cCast.input),
			output_interface=tonumber(cCast.output),
			bytes=tonumber(cCast.bytes),
			packets=tonumber(cCast.pkts),
		};

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

