
-- stateless ;
-- if you need to maintain state put it in the 'state' object 
--
local SweepBuf=require'sweepbuf'
local dbg =require'debugger'

local SSHDissector = 
{
	-- various combinations , chacha20-poly1305 is special case 

	-- for 128 bit ciphers (almost all of them) 
	--  ETM (unencrypted hdr) MACLEN,  KEYSTROKELEN,  TERMCAPLENLIUX, TERMCAPPUTTY
	ControlTable   =  
	{ 
	["hmac-md5-etm@openssh.com"]        = {etm=true,  m=16,      k=16,     t={320}    },
	["hmac-sha1-etm@openssh.com"]       = {etm=true,  m=20,      k=16,     t={320}    },		 -- checked 
	["umac-64-etm@openssh.com"]         = {etm=true,  m=8,       k=16,     t={320}    },
	["umac-128-etm@openssh.com"]        = {etm=true,  m=16,      k=16,     t={320}    },
	["hmac-sha2-256-etm@openssh.com"]   = {etm=true,  m=32,      k=16,     t={320}    },
	["hmac-sha2-512-etm@openssh.com"]   = {etm=true,  m=64,      k=16,     t={320}    },
	["hmac-sha1-96-etm@openssh.com"]    = {etm=true,  m=12,      k=16,     t={320}    },
	["hmac-md5-96-etm@openssh.com"]     = {etm=true,  m=12,      k=16,     t={320}    },
	["chacha20-poly1305@openssh.com"]   = {etm=false, m=16,      k=36,	   t={376,436,288}},   
	["hmac-sha2-256"]                   = {etm=false, m=32,      k=64,     t={304,304}    },
	["hmac-sha1"]                       = {etm=false, m=20,      k=52,     t={460,304}    },
   } ,

   MaxShellSegments = 20,


	-- 
	-- how to get the next record 
	-- SSH2.0 is simple - the first pkt looks for \r\n
	-- the others Up-Until the NEW KEYS are length
	-- after that *-etm HMACs have clear text length, others dead-end 
	-- 
	what_next =  function( tbl, pdur, swbuf)
		if tbl.ssh_state  == 0 then
			pdur:want_to_pattern("\r\n")
		elseif tbl.ssh_state == 99 then 
			pdur:abort()
		elseif tbl.ssh_state == 5 then 
			pdur:want_next(4 + swbuf:u32() + tbl.nego.ctl_table.m)
		else 
			pdur:want_next(swbuf:u32() + 4)
		end 
	end,

	-- 
	-- Helper method- select from client prefs also supported by server 
	--
	--
	negotiated = function(client, server, fieldname )
		local client_tbl, server_tbl = client[fieldname],server[fieldname]
		for i,v in ipairs(client_tbl) do 
			for k,v2 in ipairs(server_tbl) do 
				if v==v2 then return v end
			end
		end
		return nil 
	end ,

	-- onnewdata - for traffic analysis
	on_newdata = function( tbl, pdur, args )
		if tbl.ssh_state == 4 then 
			tbl:handle_post_newkeys(pdur,args)
		end
	end,


	-- handle a record
	on_record = function( tbl, pdur, strbuf)

		if tbl.ssh_state == 0 then
			tbl.ssh_version_string = strbuf
			tbl.ssh_state=1
		elseif tbl.ssh_state == 5 then 

			-- check if login successful using the SSH-MSG-CHANNEL-REQUEST for pty
			-- 
			tbl:handle_post_newkeys(pdur,strbuf)

		else 

			local sb = SweepBuf.new(strbuf)
			sb:next_u32()
			sb:next_u8()

			local code=sb:next_u8()
			if code == 20 then
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

					print("----- SSH Session Settings---- ")
					print(" Version : "..tbl.ssh_version_string.." "..tbl.role)
					print(" Version : "..pair_st.ssh_version_string.." "..pair_st.role)
					for k,v in pairs( tbl.nego ) do 
						print(k.."="..v)
					end

					if tbl.nego.encryption_algorithms_client_to_server=="chacha20-poly1305@openssh.com" then 
						tbl.nego.ctl_table =tbl.ControlTable['chacha20-poly1305@openssh.com']
					else
						tbl.nego.ctl_table =tbl.ControlTable[tbl.nego.mac_algorithms_client_to_server]
					end
					pair_st.nego = tbl.nego

					print("------------------------------ ")


				end

			elseif code==21 then
				-- if *-etm  the pktlen available use that 
				if tbl.nego.ctl_table.etm  then 
					print(tbl.role.. " NEW_KEYS - ETM will continue PDU ") 
					tbl.ssh_state=5
					tbl.shell_segments=0
				else
					print(tbl.role.. " NEW_KEYS - non-ETM work with TCP buff") 
					tbl.ssh_state=4
					tbl.shell_segments=0
				end
			end

		end
	end ,


	is_member = function( val, tbl) 
		for _,v in ipairs(tbl) do 
			if v == val then return true end
		end
		return false
	end,

	print_table = function(tbl, indent )

		indent = indent or ""
		for k,v in pairs(tbl) do 

			if type(v) == "table" then 
				print(indent..k)
				self.print_table( v, indent.."   ")
			else
				print(indent..k.."      "..v)
			end
		end 
	end,



	handle_post_newkeys=function(tbl, pdur, strbuf)

		local plen = #strbuf

		if tbl.nego.ctl_table.etm then
			local sb = SweepBuf.new(strbuf)
			plen = sb:u32()
		end

		-- check if login successful using the SSH-MSG-CHANNEL-REQUEST for pty
		-- 
		if tbl.role == 'client'   then 
			if  tbl.is_member(plen,tbl.nego.ctl_table.t) then
				print("((( LOGIN SUCCESS))))"..pdur.id)
			end
			tbl.key_press =  (plen == tbl.nego.ctl_table.k) 
		else 
			tbl.key_press =  (plen == tbl.nego.ctl_table.k) 
			if tbl.key_press and tbl.paired_with.key_press then
				print("((( KEY PRESS")
			end
			tbl.key_press=false
			tbl.paired_with.key_press=false
		end

		-- abort after a few segments past NEW_KEYS 
		tbl.shell_segments = tbl.shell_segments + 1
		if tbl.shell_segments  > tbl.MaxShellSegments then
			tbl.ssh_state=99
		end
	end


}


local sshdissector = {}

sshdissector.new_pair = function()
		print("PAIRIR")
		local p = setmetatable(  {ssh_state=0, role="server", hshake = {}},   { __index = SSHDissector})
		local q = setmetatable(  {ssh_state=0, role="client", hshake = {}},   { __index = SSHDissector})
		p.paired_with=q
		q.paired_with=p
		return p,q
end

return sshdissector;

