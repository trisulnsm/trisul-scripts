--
--  silk.lua 
--
--  Type : InputFilter
--  
--  Process flow dumps from SiLK ( cert.org/netsa) in Trisul 
--  
--  1. Use rwcat to output flow records to a named pipe
--  2. This LUA file will listen on the named pipe and push records into Trisul
--     for streaming statistical analytics
--  
--  to run 
--  1. mkfifo /tmp/silkpipe  
--  2. rwcat --ipv4-output --compression=none file1.17 file1.18   -o /tmp/silkpipe
--  3. trisulctl_probe importlua silk.lua  /tmp/silkpipe 
--

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
    uint8_t     flow_type;  /* 17     Class & Type info */
    uint16_t      sID;         /* 18-19  Sensor ID */

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

    uint32_t      sIP;         /* 40-43  (or 40-55 if IPv6) Source IP */
    uint32_t      dIP;         /* 44-47  (or 56-71 if IPv6) Destination IP */
    uint32_t      nhIP;        /* 48-51  (or 72-87 if IPv6) Routr NextHop IP*/
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
      packet:set_timestamp(ltime)
      FI.process_flow(engine, {
        first_timestamp=stime,
        last_timestamp=ltime,
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

      -- progress every 10K records 
      if T.count % 10000==0 then 
        print("Processed "..T.count .. " flows")
      end 

      -- true return, means there is more 
      return true 
            
    end,

  },

}

