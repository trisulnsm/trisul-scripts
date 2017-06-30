-- pdurecord.lua 
-- 	PDU layer attached to a stream 

local SweepBuf=require'sweepbuf'

local PDURecord = {

	-- State 0: init 
	--       1: collect mode 
	--       2: skip mode 
	--       3: abort 



	skip_next = function(tbl, bytes, cb)
		tbl.skip_to_pos = tbl.stream_pos + bytes
		tbl.next_pdu = tbl.stream_pos + bytes
		tbl.state = 2
	end,

	abort = function()
		tbl.state = 3 
	end,

	push_chunk = function( tbl, stream_pos, incomingbuf  )

		local inbuf =SweepBuf.new(incomingbuf,stream_pos)

		if inbuf <= tbl.current_buf then
			print("SMALLER "..tostring(inbuf) )
			return
		end 

		local st = tbl.state
		if st==3 then
			-- aborted 
			return
		elseif st==2 then
			-- skipping 
			local ol = tbl.next_pdu  - stream_pos 
			if ol  > 0  then 
				tbl.current_buf = SweepBuf.new(incomingbuf,tbl.next_pdu)
				tbl.stream_pos = tbl.next_pdu
				tbl.state=1
			end
		elseif st==1 then
			tbl.current_buf = tbl.current_buf + SweepBuf.new(incomingbuf,stream_pos)
		elseif st==0 then
			tbl.current_buf = SweepBuf.new(incomingbuf,stream_pos)
			tbl.state=1
		end
	end,

	want_next = function(tbl, bytes )
		return tbl.current_buf:next_str_to_len( bytes)
	end,

	want_to_pattern = function(tbl, patt )
		return tbl.current_buf:next_str_to_pattern( patt)
	end,


}

local pmt = {
	__index = PDURecord ,
	__tostring = function(p) 
			  return string.format( "PDU/%s  State=%d  Pos=%d Next=%d B=%s", 
									p.id, p.state, p.stream_pos, p.next_pdu,  p.current_buf)
	end

}

local pdurecord = {

		new = function( id  ) 

			local pstate = { 
				state =  0,   
				next_pdu = 0,
				stream_pos = 0,
			    current_buf = SweepBuf.new(""),
				id = id 
			}
				
			return setmetatable( pstate, pmt) 
		end 	
}

return pdurecord;
