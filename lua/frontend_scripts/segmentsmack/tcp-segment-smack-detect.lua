-- segment-smack detect 
-- for each connection : compute in real time ratio of 
--                       Segments_That_Create_Hole/Segment_That_Close_hole
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     handle packets and update metrics 
-- DESCRIPTION: plugin to TCP layer packet 

local SB=require'sweepbuf' 

TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "TCP Segment Analysis",
    description = "Stateful: track TCP segments  ", -- optional
  },

  -- 
  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()
    T.flowtable={} 
  end,

  -- simple_counter  block
  -- 
  simplecounter = {

    -- Required field : which protocol (layer) do you wish to attach to 
    -- TCP layer 
    protocol_guid = "{77E462AB-2E42-42ec-9A58-C1A6821D6B31}",


    -- WHEN CALLED: when the Trisul platform detects a packet at the protocol_guid layer
    -- layer  = start of  tcp packet 
    onpacket = function(engine,layer)

      local sb      = SB.new(layer:rawbytes():tostring()  )
      local flowkey   = layer:packet():flowid():key() 

      -- decode TCP we need 
      local sport=sb:next_u16()
      local dport=sb:next_u16()
      local seq_no=sb:next_u32()
      local ack_no=sb:next_u32()
      local flags_fo =sb:next_bitfield_u16( { 4, 6, 1,1,1,1,1,1 } ) 
      local header_len= flags_fo[1]
      local rst = flags_fo[6]
      local syn = flags_fo[7]
      local fin = flags_fo[8]

      -- decode IP length 
      local iplayer = layer:packet():find_layer("{0A2C724B-5B9F-4ba6-9C97-B05080558574}")
      local sbip   = SB.new(iplayer:rawbytes():tostring()  )
      local verihl =sbip:next_bitfield_u8( { 4,4 } ) 
      local ihl = verihl[2]
      sbip:skip(1) 
      local tlen   = sbip:next_u16() 
      sbip:skip(8)
      local source_ip = sbip:next_ipv4()
      local dest_ip = sbip:next_ipv4()

      -- payload 
      local payload_size  = tlen - (header_len+ihl)*4
      
      local flowkey=source_ip.."_"..dest_ip.."_"..sport.."_"..dport 
      local tbl = T.flowtable[flowkey] 
      if tbl == nil then 
        if not syn==1 then return end 
        tbl = {
          expected_seq=0;
          in_order_segments=0;
          out_of_order_segments=0;
          total_payload_size=0;
        }
        T.flowtable[flowkey] =tbl
      end 

      --print("> "..sport.." "..dport.." "..seq_no.." ".." "..header_len.." iplen="..payload_size.." exp;" ..tbl.expected_seq ) 
      if seq_no ~= tbl.expected_seq then
        tbl.out_of_order_segments=tbl.out_of_order_segments+1
      else
        tbl.in_order_segments=tbl.in_order_segments+1
      end

      tbl.total_payload_size=tbl.total_payload_size+payload_size
      tbl.expected_seq=seq_no + payload_size

      -- Push  an alert into Trisul  
      -- for this attack to be worthwhile , need atleast 1000 segments 90% of which are outof order 
      if tbl.out_of_order_segments + tbl.in_order_segments > 1000 and 
        tbl.out_of_order_segments / tbl.in_order_segments > 0.90 then 
          engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}", -- GUID for 'User Alerts' group
            layer:packet():flowid():id(),   -- flow ID
            "POTENTIAL-SEGMENTSTACK",       -- alert key , think of this as a SigID   
            1,                              -- priority
            "Unusual out of order order segments detected : ooo="..tbl.out_of_order_segments.." io="..tbl.in_order_segments   
            )
      end 

      -- housekeeping  - expire out 
      if rst ==1 or fin == 1 then 
        local avg_payload_size=tbl.total_payload_size / ( tbl.out_of_order_segments + tbl.in_order_segments ) 
        --[[
        print("Flow "..flowkey.." ended "..
            " ooo="..tbl.out_of_order_segments .. 
            " io="..tbl.in_order_segments..
            " avgpayload="..avg_payload_size)
        --]] 
        T.flowtable[flowkey]=nil 
      end

    end,
  },
}
