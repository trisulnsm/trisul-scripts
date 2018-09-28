-- ssh_dissect.lua
--
--
local SweepBuf=require'sweepbuf'
local dbg =require'debugger'
require 'md5ffi'

local SSHDissector = 
{
   ST = {               -- states 
    START=0,
    BEFORE_NEWKEYS=1,
    ABORT=2,
   },

  -- how to get the next record in SSH Protocol 
  --  1. the first pkt looks for \r\n
  --  2. the others Up-Until the NEW KEYS are length
  what_next =  function( tbl, pdur, swbuf)
    if tbl.ssh_state  == tbl.ST.START  then
      pdur:want_to_pattern("\n")
    elseif tbl.ssh_state == tbl.ST.ABORT  then 
      pdur:abort()
    elseif tbl.ssh_state == tbl.ST.BEFORE_NEWKEYS  then 
      pdur:want_next(swbuf:u32() + 4)
  else 
    pdur:abort()
    end 
  end,

  -- handle a record
  --
  on_record = function( tbl, pdur, strbuf)

    if tbl.ssh_state ==  tbl.ST.START then
      tbl.ssh_version_string = strbuf:gsub("[\r\n]","")
      tbl.ssh_state=tbl.ST.BEFORE_NEWKEYS
    elseif tbl.ssh_state == tbl.ST.BEFORE_NEWKEYS  then 

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
        tbl.hshake_complete=true

        local hashstr = table.concat(tbl.hshake.kex_algos,',') .. ';'..
            table.concat(tbl.hshake.encryption_algorithms_client_to_server,',')..';'..
            table.concat(tbl.hshake.mac_algorithms_client_to_server,',')..';'..
            table.concat(tbl.hshake.compression_algorithms_client_to_server,',')

        local haSSH = md5sum(hashstr)

        print( haSSH.." = ".. tbl.ssh_version_string)

        if tbl.role=="client" then
          pdur.engine:update_counter("{E49AA7D0-3DC8-46AC-E278-5DD07B298F0A}", 
                        haSSH, 0, 1); 

          pdur.engine:update_key_info("{E49AA7D0-3DC8-46AC-E278-5DD07B298F0A}", 
                        haSSH, tbl.ssh_version_string)
        else 
          pdur.engine:update_counter("{E49AA7D0-3DC8-46AC-E278-5DD07B298F0A}", 
                        haSSH, 1, 1); 

          pdur.engine:update_key_info("{E49AA7D0-3DC8-46AC-E278-5DD07B298F0A}", 
                        haSSH, tbl.ssh_version_string)

        end 

        pdur.engine:add_flow_edges("{E49AA7D0-3DC8-46AC-E278-5DD07B298F0A}", haSSH,  pdur.flowid) 
    

      end

    end
  end ,
}


local sshdissector = {}

sshdissector.new_pair = function()
    local p = setmetatable(  {ssh_state=0, role="server", last_alerted=0,hshake = {} },   { __index = SSHDissector})
    local q = setmetatable(  {ssh_state=0, role="client", last_alerted=0,hshake = {} },   { __index = SSHDissector})
    return p,q
end

return sshdissector;



