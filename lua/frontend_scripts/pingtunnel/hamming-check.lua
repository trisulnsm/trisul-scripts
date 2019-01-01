--
-- hamming-check.lua
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Used to detect EXFIL and C&C using ICMP ECHO
-- DESCRIPTION: Track every IP's PING payloads consecutive  hamming distance 
--              C&C will show large differences compared to PING programs  
-- 
local SB=require'sweepbuf'
local MM=require'mrumap'

local HAMMING_THRESHOLD=20

TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "ICMP Payload Check",
    description = "Payloads in ECHO/ECHO-REPLY are very similar", 
  },

  onload = function()
    T.icmp_pairs  =  MM.new(500) 
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
      
      local ctl = T.icmp_pairs:get(layer:flowkey())
      if ctl then
        local distance = hamming_distance(paystr, ctl.prev_payload)
        -- print('hamming distance='..distance, 'size='..T.icmp_pairs:size())
        if distance > HAMMING_THRESHOLD then
          ctl.hamming_threshold_crossed = ctl.hamming_threshold_crossed+1
        end
        ctl.prev_payload=paystr

        if  ctl.hamming_threshold_crossed == 5 then
          -- hey ! too much dissimilarity in ECHO payloads 
          print("Alert tunnel on ? "..layer:flowkey() )
          engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}",
              layer:flowkey(),
              "PING-TUNNEL",
              1,
              "Possible ICMP tunnel, too much variability in ECHO payloads")
        end
      else
        T.icmp_pairs:put( layer:flowkey(),{
        prev_payload=paystr,
        hamming_threshold_crossed=1
      })
      end 
    end

  },
}

-- hamming distance as a % of total length 
function hamming_distance(str1, str2)
  if #str1 ~= #str2 then return 100 end 

  local ret=0
  for i = 1, #str1 do
    if str1:byte(i) ~= str2:byte(i) then
        ret = ret + 1
    end
  end
  return ret*100/#str1
end


