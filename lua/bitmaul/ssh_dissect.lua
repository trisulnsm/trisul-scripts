
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

	-- select neg
	negotiated = function(client, server, fieldname )
		local client_tbl, server_tbl = client[fieldname],server[fieldname]
		for i,v in ipairs(client_tbl) do 
			for k,v2 in ipairs(server_tbl) do 
				if v==v2 then return v end
			end
		end
		return nil 
	end ,


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

				-- store them in the state 
				--
				tbl.hshake. kex_algos   = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. server_host_key_algorithms  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. encryption_algorithms_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. encryption_algorithms_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. mac_algorithms_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. mac_algorithms_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. compression_algorithms_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. compression_algorithms_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. languages_client_to_server  = sb:split(sb:next_str_to_len(sb:next_u32()),",")
				tbl.hshake. languages_server_to_client  = sb:split(sb:next_str_to_len(sb:next_u32()),",")

				tbl.ssh_state=2

				-- How Negotiation works - go through CLIENT preference 
				local pair_st = tbl.paired_with
				if pair_st.ssh_state==2 then

					local client_prefs  , server_prefs
					if tbl.role == 'client' then
						client_prefs = tbl.hshake
						server_prefs = pair_st.hshake
					else
						server_prefs = tbl.hshake
						client_prefs = pair_st.hshake
					end

					tbl.nego = {}
					for k,v in pairs( client_prefs) do 
						tbl.nego[ k] = tbl.negotiated(client_prefs,server_prefs,k)
					end

					print("----- NEGOTIATED SETTINGS ---- ")
					for k,v in pairs( tbl.nego ) do 
						print(k.."="..v)
					end

				end

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
		local p = setmetatable(  {ssh_state=0, role="client", hshake = {}},   { __index = SSHDissector})
		local q = setmetatable(  {ssh_state=0, role="server", hshake = {}},   { __index = SSHDissector})
		p.paired_with=q
		q.paired_with=p
		return p,q
end

return sshdissector;

