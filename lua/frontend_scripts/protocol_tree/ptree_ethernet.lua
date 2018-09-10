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
	  	sb:skip(8)
		local proto=sb:next_u8()
		sb:skip(4*ihl[2] - 10 ) 
		table.insert(protostack,proto)

		if proto == 6 or proto == 11 then 
			local useport  = math.min(sb:next_u16(), sb:next_u16())
			if useport < 1024 then
				table.insert(protostack,useport)
			else
				table.insert(protostack,65535)
			end
		end 

	  elseif etype==0x0884 then

	  else 

	  end 

	  local key = table.concat(protostack,"/")

	  print(key)

    end,


  },
}
