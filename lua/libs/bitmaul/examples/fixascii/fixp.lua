-- fixparse.lua
-- 
-- Fix Parser a byte stream using the PDU record 
local dbg=require'debugger'

local PDURec = require'pdurecord'

local FixFields = require'fixtypes'


local FixDissector  = {

  -- how to get the next record 
  -- 
  what_next =  function( tbl, pdur, swbuf)

  	if tbl.state=='init' then
		pdur:want_to_pattern("9=%d+\1")
	elseif tbl.state=='get_full_record' then 
		pdur:want_next(tbl.moredata)
	end

  end,


  -- handle a reassembled record
  --
  on_record = function( tbl, pdur, strbuf)

  	if tbl.state=='init' then
		tbl.state='get_full_record'
		tbl.header = strbuf 

		-- msg size 9=88
		local f,l,bytes = strbuf:find("9=(%d+)\1")
		tbl.moredata = tonumber(bytes) + 7 
	elseif tbl.state=='get_full_record' then 
		tbl.state='init'

		print("-----")
		for k,v in strbuf:gmatch("(%w+)=([^\1]+)\1") do
			print(FixFields[k].."="..v) 
		end



	end
	
  end ,


}

-- new 
new_fix = function()
	local p = setmetatable(  { state='init'},   { __index = FixDissector})
	return p
end 



if #arg ~= 1 then 
	print("Usage : fixp datafile")
	return
end 

local f = io.open(arg[1])

local payl = nil 
local cpos = 1 

--local payl = f:read( math.random(20) )
local payl = f:read( 200) 


local pdu1 =  PDURec.new("fixp", new_fix() )
print(pdu1)

while payl do 
	pdu1:push_chunk(cpos,payl)
	cpos = cpos + #payl
	payl = f:read( math.random(20) )
end


