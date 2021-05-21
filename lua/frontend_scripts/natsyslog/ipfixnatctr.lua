--
-- NAT IPFIX counter 
-- 
local Sw = require'sweepbuf' 
local TblInspect = require'inspect' 
local Fk = require'flowkey' 

TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "IPFIX NAT packet monitor",
    description = "Listen to IPFIX NAT packets", 
  },

  -- COMMON FUNCTIONS:  onload, onunload, onmessage 
  -- 
  -- WHEN CALLED : your LUA script is loaded into Trisul 
  onload = function()

  end,

  -- WHEN CALLED : your LUA script is unloaded  / detached from Trisul 
  onunload = function()
    -- your code 
  end,

  simplecounter = {

	-- to UDP>IPFIX protocol 
    protocol_guid = "{F15F08A9-F3E0-4722-4D97-31CCF0743E4E}",

    onpacket = function(engine,layer)
		local sw = Sw.new(layer:rawbytes():tostring())

		local v, c, sysup, tvsec  = sw:next_u16(), sw:next_u16(), sw:next_u32(), sw:next_u32() 

		local seq, sourceid = sw:next_u32(), sw:next_u32() 

		while sw:has_more() do 

			local fsid = sw:next_u16()
			local fslen = sw:next_u16()

			if fsid==262 then

				sw:push_fence(fslen - 4 ) 
				while sw:has_more() do

					local pp = TrisulPlugin.parse_nat_template_262( sw) 
					-- print(TblInspect(pp))

					local fkey = Fk.toflow_format_v4( pp.proto, pp.sip_nat, pp.sp_nat, pp.dip, pp.dp)

					if pp.reason   == 1  then
						engine:update_flow_raw( fkey, 0, 1)
						engine:tag_flow ( fkey, "[natip]"..pp.sip)
						engine:tag_flow ( fkey, "[natport]"..pp.sp)
					elseif pp.reason  == 2 then 
						engine:update_flow_raw( fkey, 0, 1)
						engine:terminate_flow ( fkey)
					end 
	
				end 
				
			else
				sw:skip( fslen-4) 
			end 

		end 

    end,

  },

	-- return a table 
	parse_nat_template_262 = function(sw)
		return {
			sip = sw:next_ipv4(),
			sip_nat = sw:next_ipv4(),
			dip  = sw:next_ipv4(),
			dip_nat = sw:next_ipv4(),
			sp = sw:next_u16(),
			sp_nat = sw:next_u16(),
			dp = sw:next_u16(),
			dp_nat = sw:next_u16(),
			vrf = sw:next_u32(),
			proto = sw:next_u8(),
			reason = sw:next_u8(),
			obs_hi = sw:next_u32(),
			obs_lo = sw:next_u32(), 
		}

	end, 
}

