
-- stateless ;
-- if you need to maintain state put it in the 'state' object 
--
local SSHDissector = 
{

	-- how to get the next record 
	what_next =  function( tbl, pdur, swbuf)
		if tbl.ssh_state  == 0 then
			pdur:want_to_pattern("\r\n")
		elseif tbl.ssh_state == 1 then
			pdur:want_next(swbuf:u32() + 4)
		else 
			pdur:abort()
		end 
	end,


	-- handle a record
	on_record = function( tbl, pdur, strbuf)
		print("GOT tbl len="  .. #strbuf)
		tbl.ssh_state=1
	end ,


local sshdissector = {}

sshdissector.new = function() 
	   return setmetatable(  {ssh_state=0},   { __index = SSHDissector})
end,

sshdissector.new_pair = function()
		local p = setmetatable(  {ssh_state=0},   { __index = SSHDissector})
		local q = setmetatable(  {ssh_state=0},   { __index = SSHDissector})
		p.paired_with=q
		q.paired_with=p
		return p,q
end,

return sshdissector;

