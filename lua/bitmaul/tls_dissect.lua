--
-- pulls out TLS records 
-- 
--  totally stateless 
-- 
local TLSDissector  = 
{

	-- how to get the next record 
	-- easy  2 bytes at offset 3 
	what_next =  function( tbl, pdur, swbuf)
		swbuf:inc(3)
		local reclen  = swbuf:u16()
		print("WANT "..reclen)
		swbuf:inc(-3)
		pdur:want_next(reclen + 5)
	end,


	-- handle a record
	on_record = function( tbl, pdur, strbuf)
		print("TLS record ="  .. #strbuf)
	end ,


}

return { 
   	new = function() 
	   return setmetatable( {}, { __index = TLSDissector})
	end
} 


