-- pdurecord.lua 
--
--  generates PDU records from a stream
--
local SweepBuf=require'sweepbuf'

local dbg=require 'debugger'

local PDURecord = {

    -- States
    --       0: start 
    --       1: want_bytes
    --       2: want_pattern
    --       3: skip_bytes 
    --       4: abort 

    -- TODO: unoptimized 
    -- 
    push_chunk = function( tbl, segment_seek, incomingbuf  )

      local st = tbl.state

      local newdatalen  = segment_seek + #incomingbuf - tbl.head_pos 
      tbl.head_pos = tbl.head_pos + newdatalen
      if newdatalen == 0  then
        return
      elseif tbl.diss.on_newdata then 
        if tbl.state==4 then 
            tbl.diss:on_newdata(tbl, newdatalen , nil ) 
            return 
        else
            tbl.diss:on_newdata(tbl, newdatalen, string.sub(incomingbuf,-newdatalen))
        end 
      end 

      -- fast cases 
      if st==4 then 
        return  -- abort
      elseif st==3 and segment_seek + #incomingbuf <= tbl._sweepbuffer.abs_seek()  then
        return  -- skip mode , streaming will resume at tbl.seek 
      elseif segment_seek + #incomingbuf > tbl._sweepbuffer.right then
        -- update buffer  
        tbl._sweepbuffer = tbl._sweepbuffer + SweepBuf.new(incomingbuf,segment_seek)
      elseif not tbl._sweepbuffer:has_more() then
        return
      end 

      -- print("SWEEP + " .. tostring(tbl._sweepbuffer))

      local run_pump = true
      while run_pump do 
        st=tbl.state 

        run_pump=false
        if st==4 then
          -- STATE abort 
        elseif st==3 then 
          -- STATE skipping 
          local ol = tbl.skip_to_pos - segment_seek
          if ol  > 0  then 
              tbl._sweepbuffer = SweepBuf.new(string.sub(incomingbuf,ol),tbl.skip_to_pos)
              tbl.state=0
          else
              return
          end
        elseif st==2 then
          -- STATE want pattern
          local mb = tbl._sweepbuffer:next_str_to_pattern(tbl.want_pattern)
          if mb then 
              tbl.diss:on_record(tbl, mb )    --> * emit *
              tbl.state=0
              run_pump=true
          end
        elseif st==1 then
          -- STATE_want bytes
          if  tbl._sweepbuffer:bytes_left() >= tbl.want_bytes then  
              local nbuff  = tbl._sweepbuffer:next_str_to_len(tbl.want_bytes)
              tbl.diss:on_record(tbl, nbuff )     --> * emit *
              tbl.state=0
              run_pump=true
          end
        elseif st==0 and tbl._sweepbuffer:has_more() then
          tbl.diss:what_next( tbl, tbl._sweepbuffer)
		  run_pump = (tbl.state ~= 0)
        end

		run_pump = run_pump and (tbl.state ~= 4) 

      end

    end,

    -- state changes
    want_next = function(tbl, bytes )
      tbl.want_bytes=bytes
      tbl.state =1
    end,

    want_to_pattern = function(tbl, patt )
      tbl.want_pattern=patt
      tbl.state =2
    end,

    skip_next = function(tbl, bytes)
      local skip_to_pos = tbl._sweepbuffer.abs_seek() + bytes
      tbl._sweepbuffer = SweepBuf.new("",skip_to_pos)
      tbl.state = 3
    end,

    -- cant restart from here , let GC pick up right away  
    abort = function(tbl)
      tbl.state = 4 
      tbl.aborted_at_pos = tbl._sweepbuffer.right
      tbl._sweepbuffer = nil 
    end,


}

local pmt = {
    __index = PDURecord ,
    __tostring = function(p) 
          return string.format( "PDU/%s  State=%d  B=%s", 
                          p.id, p.state, tostring(p._sweepbuffer))
    end

}

local pdurecord = {

  new = function( id , dissector  ) 

    local pstate = { 
      id = id ,
      state =  0,   
      diss = dissector,
      head_pos = 0,
      timestamp=0,
      _sweepbuffer = SweepBuf.new("",0)
    }
        
    return setmetatable( pstate, pmt) 
  end     
}

return pdurecord;
