local SB=require'sweepbuf' 

TrisulPlugin = { 

  id =  {
    name = "Ethernet ",
    description = "for making a protocol tree ", -- optional
  },

  -- simple_counter  block
  -- 
  simplecounter = {

	-- attach to ethernet layer 
    protocol_guid = "{974FB098-DE46-45db-94DA-8D64A3BBCDE5}",

	-- ethertype 
	-- 
    onpacket = function(engine,layer)
      local sb      = SB.new(layer:packet():rawbytes():tostring()  )

	  local protostack={};

      -- ethertype 
      sb:skip(12)
      local etype=sb:next_u16()
	  table.insert(protostack,etype)

	  if etype==0x0800 then

	  	local ihl = sb:next_bitfield_u8( {4,4} ) 
	  	sb:skip(6)
		local flags_fragoff = sb:next_bitfield_u8( {1,1,1,1,12})
		sb:skip(1)
		local proto=sb:next_u8()
		sb:skip(4*ihl[2] - 10 ) 
		table.insert(protostack,proto)

		if flags_fragoff[3]==1 or flags_fragoff[5] > 0 then
			table.insert(protostack,"frag")
		elseif proto == 6 or proto == 17 then 
			local useport  = math.min(sb:next_u16(), sb:next_u16())
			if useport < 1024 then
				table.insert(protostack,useport)
			else
				table.insert(protostack,65535)
			end
		elseif proto==1 then
			table.insert(protostack,sb:next_u8())
		end 

	  elseif etype==0x86DD then
	  	sb:skip(6)
		local proto=sb:next_u8()
		table.insert(protostack,proto)

		sb:skip(33)
		if proto == 6 or proto == 17 then 
			local useport  = math.min(sb:next_u16(), sb:next_u16())
			if useport < 1024 then
				table.insert(protostack,useport)
			else
				table.insert(protostack,65535)
			end
		elseif proto==1 then
			table.insert(protostack,sb:next_u8())
		end 


	  else 

	  end 

	  local key = table.concat(protostack,"/")

	  -- print(key)

	  engine:update_counter_bytes("{2CF4DCFF-77E5-45E9-AA03-8D827CE0813C}",key,0)
	  engine:update_counter("{2CF4DCFF-77E5-45E9-AA03-8D827CE0813C}",key,1,1)


    end,


  },
}
