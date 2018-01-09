-- .lua
--
-- snmp_walkpoll.lua
-- Update Trisul Counters based on SNMP walk 
--
-- GUID  of new counter group SNMP-Interface = {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a} 

local lsqlite3 = require 'lsqlite3'
local JSON=require'JSON'

local WEBTRISUL_DATABASE="/usr/local/share/webtrisul/db/webtrisul.db"
--local WEBTRISUL_DATABASE= "/home/devbox/bldart/z21/webtrisul/db/webtrisul.db"

-- return { key, value } 
function do_bulk_walk( agent, version, community, oid  )
  command = "snmpbulkwalk"
  if version == "1" then command="snmpwalk" end
  local tstart = os.time()
  local h = io.popen(command.." -r 1 -O q -t 3  -v"..version.." -c '"..community.."' "..agent.."  "..oid)
  print(command.." -r 1 -O q -t 3  -v"..version.." -c '"..community.."' "..agent.."  "..oid)

  local ret = { } 
  for oneline in h:lines()
  do
    local  k,v = oneline:match("%.(%d+)%s+(.+)") 
    ret[agent.."_"..k] = v:gsub('"','')
  end 
  h:close()

  print("Done with agent "..agent.." elapsed secs="..os.time()-tstart)
  return ret
end

TrisulPlugin = {

  id = {
    name = "SNMP Interface",
    description = "Per Interface Stats : Key Agent:IfIndex ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },

  countergroup = {
    control = {
      guid = "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}",
      name = "SNMP-Interface",
      description = "Traffic using SNMP input ",
      bucketsize = 60,
    },
    meters = {
      {  0, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "Total BW",   "Bps" },
      {  1, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "In Octets",  "Bps" },
      {  2, T.K.vartype.DELTA_RATE_COUNTER,      20, "bytes", "Out Octets",  "Bps" },
    },
  },



  -- load polling targets from DB 
  onload = function()
    T.poll_targets = TrisulPlugin.load_poll_targets(WEBTRISUL_DATABASE)
  end,

  engine_monitor = {

    -- only do this from Engine 0. Run thru each port and send separat SNMP get 
    onbeginflush = function(engine, tv)

      for _,agent in ipairs(T.poll_targets) do 

        -- update IN 
        local oid = ".1.3.6.1.2.1.31.1.1.1.6"
        if agent.agent_version == "1"  then oid = "1.3.6.1.2.1.2.2.1.10" end
        print("Engine-"..engine:id().." BulkWalk start for "..agent.agent_ip)
        local bw_in =  do_bulk_walk( agent.agent_ip, agent.agent_version,  agent.agent_community, oid)
        local has_varbinds = false
        for k,v in pairs( bw_in) do 
          v = tonumber(v) or 0
          engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}", k, 1, tonumber(v)  );
          has_varbinds=true
        end
  
        if not has_varbinds then
          T.logerror("SNMP Poll Failed for "..agent.agent_ip.." with v"..agent.agent_version.." comm = "..agent.agent_community)
        end 
  
          -- update OUT 
        local oid = ".1.3.6.1.2.1.31.1.1.1.10"
        if agent.agent_version == "1"  then oid = "1.3.6.1.2.1.2.2.1.16" end
        if has_varbinds then 
          local bw_in =  do_bulk_walk( agent.agent_ip, agent.agent_version, agent.agent_community, oid)
          for k,v in pairs( bw_in) do 
            v = tonumber(v) or 0
            engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}", k, 2, tonumber(v)   );
          end

          -- update keys - ALIAS iii
          local oid = ".1.3.6.1.2.1.31.1.1.1.18"
          if agent.agent_version == "1"  then oid = "1.3.6.1.2.1.2.2.1.2" end
          local up_key =  do_bulk_walk( agent.agent_ip, agent.agent_version, agent.agent_community, oid)
          for k,v in pairs( up_key) do 
            --print("UPDAING KEY ".. k .." = " .. v ) 
            engine:update_key_info( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}", k, v   );
          end
        end
      end 

    end,  -- onbeginflush 

    -- every interval reload the map -
    onendflush = function(engine,tv)
      local new_targets =  TrisulPlugin.load_poll_targets(engine:instanceid(), WEBTRISUL_DATABASE)
      if new_targets ~= nil then
        T.poll_targets = TrisulPlugin.load_poll_targets(engine:instanceid(),WEBTRISUL_DATABASE)
      end
    end,

  },


  -- load polling targets from sqlite3 database 
  -- in this case webtrisul db 
  -- return { agent => [ifindex] } mappings 
  load_poll_targets = function(engine_id, dbfile)

    T.log(T.K.loglevel.INFO, "Loading SNMP targets for polling from DB "..dbfile)

    local status,db=pcall(lsqlite3.open,dbfile);
    if not status then
      T.logerror("Error open lsqlite3 err="..db)
      return nil
    end 


    local status, stmt=pcall(db.prepare, db,  "SELECT name, value FROM WEBTRISUL_OPTIONS WHERE  webtrisul_option_type_id = 2 and id >= 10000");
    if not status then
      db:close() 
      T.logerror("Error prepare lsqlite3 err="..stmt)
      return nil
    end 
    local targets = {} 


    local ok, stepret = pcall(stmt.step, stmt) 
    while stepret  do
      local v = stmt:get_values()
      local  snmp = JSON:decode(v[2])
	  if T.util.hash( snmp["IP Address"],1) == tonumber(engine_id) then 
		  targets[ #targets + 1] = { agent_ip = snmp["IP Address"], agent_community = snmp["Community"], agent_version = snmp["Version"] } 
		  T.log(T.K.loglevel.INFO, "Loaded ip="..snmp["IP Address"].." version"..snmp["Version"].." comm=".. snmp["Community"])
		  print("Loaded ip="..snmp["IP Address"].." version"..snmp["Version"].." comm=".. snmp["Community"])
	  else
		  T.log(T.K.loglevel.INFO, "SKIPPED ip="..snmp["IP Address"].." version"..snmp["Version"].." comm=".. snmp["Community"])
		  print("SKIPPED ip="..snmp["IP Address"].." version"..snmp["Version"].." comm=".. snmp["Community"])
	  end 
      ok, stepret = pcall(stmt.step, stmt) 
    end
    stmt:finalize()


    -- community string     
    local status,stmt2=pcall(db.prepare, db, "SELECT value FROM WEBTRISUL_OPTIONS where name='default_snmpv2_community';");
    if not status then
      db:close() 
      T.logerror("Error prepare err="..stmt2)
      return nil
    end 

    ok, stepret = pcall(stmt.step, stmt) 
    if stepret then 
      T.default_community = stmt2:get_value(0)
    else 
      T.default_community = 'public'
    end 
    stmt2:finalize()

    db:close()

    return targets

  end, 

}

