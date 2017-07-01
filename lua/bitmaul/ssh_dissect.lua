
-- stateless ;
-- if you need to maintain state put it in the 'state' object 
--
local SweepBuf=require'sweepbuf'
local dbg =require'debugger'

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
		if tbl.ssh_state == 0 then
			print("SSH version string = " .. strbuf)
			tbl.ssh_state=1

		elseif tbl.ssh_state==1 then
			local sb = SweepBuf.new(strbuf)
			print("LELELEL = ".. sb:next_u32())
			sb:next_u8()
			local code = sb:next_u8()
			if code == 20 then
				print("KEY_EXCHANGE_INIT") 

				sb:skip(16) -- cookie
				local kex_algos   = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local server_host_key_algorithms  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local encryption_algorithms_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local encryption_algorithms_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local mac_algorithms_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local mac_algorithms_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local compression_algorithms_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local compression_algorithms_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local languages_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				local languages_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")

				print("KEX")
				for _,v in ipairs(kex_algos) do print(v) end 
				print("SHOSTKEY")
				for _,v in ipairs(server_host_key_algorithms) do print(v) end 
				print("ENC_C_S")
				for _,v in ipairs(encryption_algorithms_client_to_server) do print(v) end 
				print("ENC_S_C")
				for _,v in ipairs(encryption_algorithms_server_to_client) do print(v) end 
				print("MAC_S_C")
				for _,v in ipairs(mac_algorithms_client_to_server) do print(v) end 
				print("MAC_C_S")
				for _,v in ipairs(mac_algorithms_server_to_client) do print(v) end 
				print("LANG_C_S")
				for _,v in ipairs(languages_client_to_server) do print(v) end 


			elseif code==21 then
				print("NEW_KEYS") 
			elseif code==31 then
				print("DIFFIE_HELLMAN_KEY_EXCHANGE_REPLY") 
			end


		end
	end ,

}


local sshdissector = {}

sshdissector.new = function() 
	   return setmetatable(  {ssh_state=0},   { __index = SSHDissector})
end

sshdissector.new_pair = function()
		local p = setmetatable(  {ssh_state=0},   { __index = SSHDissector})
		local q = setmetatable(  {ssh_state=0},   { __index = SSHDissector})
		p.paired_with=q
		q.paired_with=p
		return p,q
end

return sshdissector;

