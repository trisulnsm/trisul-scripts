-- TLS dissector
-- 
local Sbuf=require'sweepbuf'
local Pdur=require'pdurecord'


local TLSDissector_SNI = 
{

	-- For TLS 2 bytes at offset 3  is the record length 
	-- after client hello, we arent interested in this flow 
	-- 
	what_next =  function( tbl, pdur, swbuf)
		if tbl.state=="init" then 
			pdur:want_next(swbuf:peek_u16(3) + 5)
		elseif tbl.state=="client-hello-done" then
			pdur:abort()
		end
	end,


	-- handle a record 
	-- only client_hello 
	on_record = function( tbl, pdur, strbuf)
		local payload=Sbuf.new(strbuf)

		if payload:next_u8() == 22 and payload:skip(4) and payload:next_u8() == 1 then

		  payload:reset()
		  payload:inc(5)
		  payload:next_u8()                   -- over handshake_type
		  payload:next_u24()                  -- over handshake_length 
		  payload:next_u16()				  -- pkt len
		  payload:skip(32)                    -- over client_random
		  payload:skip(payload:next_u8())     -- over SessionID if present 
		  payload:skip(payload:next_u16())    -- over Ciphers 
		  payload:skip(payload:next_u8())     -- over compression 

		  payload:push_fence(payload:next_u16())
		  while payload:has_more() do
			local ext_type = payload:next_u16()
			local ext_len =  payload:next_u16()
			if ext_type == 0 then
			  payload:push_fence(payload:next_u16())
			  while payload:has_more() do
				  payload:skip(1)
				  local snihostname  =  payload:next_str_to_len(payload:next_u16())

				  if #snihostname >=64 then
				  	snihostname = string.sub(snihostname,1,64)
				  end

				  -- hits 
				  pdur.engine:update_counter("{38497403-23FB-4206-65C2-0AD5C419DD53}",
				  						snihostname, 1, 1)

				  -- flow counter for volume/bandwidth 
				  pdur.engine:add_flow_counter(
				  	    tbl.flowkey:id(), -- flowid 
						"{38497403-23FB-4206-65C2-0AD5C419DD53}", -- SNI counter group 
						snihostname,   -- key is the SNI host name 
						0, 	           -- meter id =0 
						0)			   -- direction = BOTH 

				  -- resource 
				  pdur.engine:add_resource("{258DEBA6-B40D-4306-A5DA-DE194064DA7D}",
				  		tbl.flowkey:id(),
						snihostname,
						tbl.flowkey:ipz_readable().."="..snihostname)


				  -- print("SNI="..snihostname)
			  end
			  payload:pop_fence()
			else
			  payload:skip(ext_len)
			end
		  end
		  payload:pop_fence()

		  tbl.state="client-hello-done"
		end
    
	end ,

}

return { 
   	new= function(key) 
		local p = setmetatable(  {flowkey=key, state="init"},   { __index = TLSDissector_SNI})
		return p
	end
} 


