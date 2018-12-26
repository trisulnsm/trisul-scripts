--
-- icmp-echo-check.lua
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Compare if ECHO and ECHO reply payload matches 
-- DESCRIPTION: ICMP ECHO (ping) gets through most firewalls , so a good candidate for
--              building a C&C channel. This script checks for echo/reply match
-- 
local SB=require'sweepbuf'

TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "ICMP Echo Check",
    description = "Payload in ECHO/REPLY must match in real PINGs", 
  },


  onload = function()
	 T.icmp_echo_pending = {} 
  end,

  -- simple_counter  block
  -- 
  simplecounter = {

    -- latch on to ICMP protocol 
    protocol_guid = "{7DDD65F2-A316-43B5-A103-368E700E045E}",


    -- icmp lands here 
    onpacket = function(engine,layer)
	    local sb = SB.new( layer:rawbytes():tostring() )
	    local t =sb:next_u8()
	    if t ~= 0 and t ~= 8 then return end

	    local c,_,id,seqno=  sb:next_u8(),
				 sb:next_u16(),
				 sb:next_u16(),
				 sb:next_u16()

	    local paystr = sb:buffer_left()
	    local hsh=T.util.hash(paystr,32)
	    local flowid=layer:packet():num_layers()

	    -- need the ips + id 
	    local iplayer=layer:packet():find_layer('{0A2C724B-5B9F-4BA6-9C97-B05080558574}')
	    local sbip = SB.new(iplayer:rawbytes():tostring())
	    local _,sip,dip=sbip:skip(12), sbip:next_ipv4(), sbip:next_ipv4()
	    local icmpflowkey 
	    if t==0 then
		    icmpflowkey=sip.."-"..dip.."-"..id
		    T.icmp_echo_pending[icmpflowkey]=hsh
		    print("\nadding    "..icmpflowkey.." = "..hsh )
	    else
		    icmpflowkey=dip.."-"..sip.."-"..id
		    -- check replies hash
		    --
		    local req_hash = T.icmp_echo_pending[icmpflowkey]
		    print("checking  -"..icmpflowkey.." = "..req_hash)
		    if req_hash and req_hash ~= hsh then
			    print("Alert tunnel on ? "..icmpflowkey)
			    -- HEY! funny stuff, req and resp payloads dont match
			    -- something gooffy, raise alert
			    engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}",
			    		     "06A:00.00.00.00_icmp00:00.00.00.00_icmp01",
					     "PING-TUNNEL",
					     1,
					     "Possible ICMP Echo (Ping) tunnel, payloads dont match")
		    end
		    T.icmp_echo_pending[icmpflowkey]=nil
	    end 

    end,


  },
}
