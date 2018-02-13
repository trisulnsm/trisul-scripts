--
-- Netflow v5 Generator 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Generates Netflow v5 Records 
-- DESCRIPTION: Plugs into Flow Flushes and transmits netflow v5 records 
--              compatible with all flow collectors. 
-- 

local ffi = require'nfffi'

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

    onbeginflush = function(engine, timestamp)
		T.flow_flush_time = timestamp 
		T.boot_time = T.boot_time or timestamp 

		print("boot ".. T.boot_time)
	end,


    -- WHEN CALLED: before a flow is flushed to the Hub node  
	-- build a packet , then send when UDP datagram is full - about 25 records per packet 
    onflush = function(engine, flow) 

		-- packet being filled up 
		if T.nf5_Packet == nil then
			local nf5_Packet = ffi.new("nf5_packet");
			ffi.C.memset(nf5_Packet,0,ffi.sizeof(nf5_Packet))
			nf5_Packet.header.version = ffi.C.htons(5);
			nf5_Packet.header.count   = ffi.C.htons(0);
			nf5_Packet.header.flow_id = ffi.C.htonl(1);
			nf5_Packet.header.engine_type = 0;
			nf5_Packet.header.engine_id = 0;
			nf5_Packet.header.sampling = 0 ;
			T.nf5_Packet = nf5_Packet
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

		-- flow timestamps 
		local from,to = flow:time_window() 
		rec.sysuptime_from = (from - T.boot_time)* 1000
		rec.sysuptime_to = (to - T.boot_time)* 1000

		-- done with this record 
		T.nf5_Packet.header.count = T.nf5_Packet.header.count+1
		T.sequence_no = T.sequence_no + 1 

		-- header count  -note we leave 2 spots empty for 
		-- next fwd and reverse flows 
		if T.nf5_Packet.header.count > 23 then

			-- wrap up header items 
			local sec,us = flow:time_window() 
			T.nf5_Packet.header.sysuptime=ffi.C.htonl((T.flow_flush_time - T.boot_time)*1000 )
			T.nf5_Packet.header.tv_sec = ffi.C.htonl(T.flow_flush_time)
			T.nf5_Packet.header.tv_nsec = ffi.C.htonl(0)
			T.nf5_Packet.header.flow_id=ffi.C.htonl(T.sequence_no)

			local ret = ffi.C.sendto(  T.socket,  T.nf5_Packet, ffi.sizeof(T.nf5_Packet),  0,
							 ffi.cast("const struct sockaddr*",T.dest_addr), ffi.sizeof(T.dest_addr) );
			if  ret == -1 then 
			  print("Error sendto() " .. strerror())
			  return 
			end 
			T.nf5_Packet = nil;
		end

    end,

	-- endflush : Flush out any partial netflow packet 
    onendflush = function(engine)
		-- wrap up leftover header items 
		if T.nf5_Packet then 
			T.nf5_Packet.header.sysuptime=ffi.C.htonl((T.flow_flush_time - T.boot_time)*1000 )
			T.nf5_Packet.header.tv_sec = ffi.C.htonl(T.flow_flush_time)
			T.nf5_Packet.header.tv_nsec = ffi.C.htonl(0)

			local ret = ffi.C.sendto(  T.socket,  T.nf5_Packet, ffi.sizeof(T.nf5_Packet),  0,
							 ffi.cast("const struct sockaddr*",T.dest_addr), ffi.sizeof(T.dest_addr) );
			if  ret == -1 then 
			  print("Error sendto() " .. strerror())
			  return 
			end 
			T.nf5_Packet = nil;
		end 
	end,

  },

}
