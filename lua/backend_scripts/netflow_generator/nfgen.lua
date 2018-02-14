--
-- Netflow v5 Generator 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Generates Netflow v5 Records 
-- DESCRIPTION: Plugs into Flow Flushes and transmits netflow v5 records 
--              compatible with all flow collectors. 
-- 

local ffi = require'nfffi'
local bit = require'bit'

--
--  Config Params
--
local NETFLOW_COLLECTOR_HOST = "192.168.2.11"
local NETFLOW_COLLECTOR_PORT = 2055
--
-- 


function strerror()
  return ffi.string(ffi.C.strerror( ffi.errno() ))
end

TrisulPlugin = { 

  id =  {
    name = "Netflow Generator",
    description = "App generates Netflow v5 from Trisul  ",
  },


  -- WHEN CALLED : your LUA script is loaded into Trisul 
  -- setup the socket and the FFI base 
  onload = function()

    -- setup socket 
    local K = ffi.new("struct constants");
    local socket = ffi.C.socket( K.AF_INET, K.SOCK_DGRAM, 0);
    if  socket == -1 then 
      print("Error socket() , script wont load " .. strerror())
      return  false 
    end 
    T.socket = socket

    -- create destrination bsd address 
    local addr=ffi.new("struct sockaddr_in");
    ffi.fill(addr,ffi.sizeof(addr));
    addr.sin_family = K.AF_INET;
    addr.sin_addr = ffi.C.inet_addr("192.168.2.19"); 
    addr.sin_port = ffi.C.htons(2055);
    T.dest_addr = addr

    -- basic resets
    T.boot_time = nil 
    T.flow_flush_time = nil 
    T.sequence_no = 1 

  end,


  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    ffi.C.close(T.socket)
  end,

  -- sg_monitor block
  -- sg = session group
  sg_monitor  = {

    -- WHEN CALLED: before a flush operation starts , called approx 1 min
    onbeginflush = function(engine, timestamp)
      T.flow_flush_time = timestamp 
      T.boot_time = T.boot_time or timestamp 
    end,

    -- WHEN CALLED: before a flow is flushed to the Hub node  
    -- build a packet , then send when UDP datagram is full - about 25 records per packet 
    onflush = function(engine, flow) 

      -- packet being filled up 
      if T.nf5_Packet == nil then
        T.nf5_Packet = ffi.new("nf5_packet");
        ffi.C.memset(T.nf5_Packet,0,ffi.sizeof(T.nf5_Packet))
      end

      -- copy the new flow into the packet 
      local rec = T.nf5_Packet.records[T.nf5_Packet.header.count]
      rec.source_ip = ffi.C.inet_addr( flow:flow():ipa_readable())
      rec.dest_ip   = ffi.C.inet_addr( flow:flow():ipz_readable())
      rec.source_port = ffi.C.htons( tonumber(flow:flow():porta_readable()) )
      rec.dest_port = ffi.C.htons( tonumber(flow:flow():portz_readable()) )
      rec.byte_count = ffi.C.htonl( tonumber( flow:az_bytes()))
      rec.packet_count = ffi.C.htonl( tonumber( flow:az_packets()))
      rec.l4_protocol = tonumber(flow:flow():protocol(),16)

      -- compute tcp_flags from state
      local flags = 0
      if bit.band(flow:state(),0x0002) then 
        flags = bit.bor(flags,0x02)  -- syn
      end 
      if bit.band(flow:state(),0x0040) then 
        flags = bit.bor(flags,0x01)  -- fin 
      end
      if bit.band(flow:state(),0x0080) then 
        flags = bit.bor(flags,0x04)  -- rst 
      end
      rec.tcp_flags=flags;

      -- flow timestamps 
      local from,to = flow:time_window() 
      rec.sysuptime_from = ffi.C.htonl((from - T.boot_time)* 1000)
      rec.sysuptime_to = ffi.C.htonl((to - T.boot_time)* 1000)

      -- done with this record 
      T.nf5_Packet.header.count = T.nf5_Packet.header.count+1
      T.sequence_no = T.sequence_no + 1 

      -- reverse direction 
      rec = T.nf5_Packet.records[T.nf5_Packet.header.count]
      rec.source_ip = ffi.C.inet_addr( flow:flow():ipz_readable())
      rec.dest_ip   = ffi.C.inet_addr( flow:flow():ipa_readable())
      rec.source_port = ffi.C.htons( tonumber(flow:flow():portz_readable()) )
      rec.dest_port = ffi.C.htons( tonumber(flow:flow():porta_readable()) )
      rec.byte_count = ffi.C.htonl( tonumber( flow:za_bytes()))
      rec.packet_count = ffi.C.htonl( tonumber( flow:za_packets()))
      rec.l4_protocol = tonumber(flow:flow():protocol(),16)
      rec.tcp_flags=flags;
      rec.sysuptime_from = ffi.C.htonl((from - T.boot_time)* 1000)
      rec.sysuptime_to = ffi.C.htonl((to - T.boot_time)* 1000)

      -- done with this record 
      T.nf5_Packet.header.count = T.nf5_Packet.header.count+1
      T.sequence_no = T.sequence_no + 1 


      -- header count  -note we leave 2 spots empty for 
      -- next fwd and reverse flows 
      if T.nf5_Packet.header.count > 22 then
        flush_packet(T.nf5_Packet)
        T.nf5_Packet = nil;
      end

    end,

    -- WHEN CALLED: a flush cycle finished 
    --         Flush out any partial netflow packet 
    onendflush = function(engine)
      -- wrap up leftover header items 
      if T.nf5_Packet then 
        flush_packet(T.nf5_Packet)
        T.nf5_Packet = nil;
      end 
    end,
  },
}


--
-- send out the Netflow pkt via UDP 'sendto'
flush_packet = function( pkt)
  local nrecs = pkt.header.count 
  if nrecs == 0 then return end 
  pkt.header.version = ffi.C.htons(5);
  pkt.header.count = ffi.C.htons(pkt.header.count)
  pkt.header.sysuptime = ffi.C.htonl((T.flow_flush_time - T.boot_time)*1000 )
  pkt.header.tv_sec = ffi.C.htonl(T.flow_flush_time)
  pkt.header.tv_nsec = ffi.C.htonl(0)
  pkt.header.flow_id=ffi.C.htonl(T.sequence_no)

  local ret = ffi.C.sendto(  T.socket,  pkt, 
                      ffi.sizeof(pkt.header)+nrecs*ffi.sizeof(pkt.records[0]),  0,
                      ffi.cast("const struct sockaddr*",T.dest_addr), ffi.sizeof(T.dest_addr) );
  if  ret == -1 then 
    print("Error sendto() " .. strerror())
    return 
  end 
end 

