-- .lua
--
-- snmp_walkpoll.lua
-- Update Trisul Counters based on SNMP walk 
--
-- GUID  of new counter group SNMP-Interface = {9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a} 

local lsqlite3 = require 'lsqlite3'
local dbg = require'debugger'
local WEBTRISUL_DATABASE="/home/vivek/bldart/z01/webtrisul/db/webtrisul.db"
-- local WEBTRISUL_DATABASE="/usr/local/share/webtrisul/db/webtrisul.db"

-- return { key, value } 
function do_bulk_walk( agent, community, oid  )
  local h = io.popen("snmpbulkwalk -O q  -v2c -c '"..community.."' "..agent.."  "..oid)

  local ret = { } 

  for oneline in h:lines()
  do
	local  k,v = oneline:match("%.(%d+)%s+(.+)") 
	ret[agent.."_"..k] = v:gsub('"','')
  end 
  h:close()

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

      if engine:instanceid() ~= "0" then return end 

      for _,agent in ipairs(T.poll_targets) do 

		-- update IN 
	  	local bw_in =  do_bulk_walk( agent.agent_ip, agent.agent_community, ".1.3.6.1.2.1.31.1.1.1.6")
		for k,v in pairs( bw_in) do 
          engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}", k, 1, tonumber(v)  );
		end
	
		-- update OUT 
	  	local bw_in =  do_bulk_walk( agent.agent_ip, agent.agent_community, ".1.3.6.1.2.1.31.1.1.1.10")
		for k,v in pairs( bw_in) do 
          engine:update_counter( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}", k, 2, tonumber(v)   );
		end

		-- update keys - ALIAS 
	  	local up_key =  do_bulk_walk( agent.agent_ip, agent.agent_community, ".1.3.6.1.2.1.31.1.1.1.18")
		for k,v in pairs( up_key) do 
   		  print("UPDAING KEY ".. k .." = " .. v ) 
          engine:update_key_info( "{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}", k, v   );
		end
      end 

    end,

    -- every interval reload the map -
    onendflush = function(engine,tv)
      if engine:instanceid() ~= "0" then return end 

      T.poll_targets = TrisulPlugin.load_poll_targets(WEBTRISUL_DATABASE)

    end,

  },


  -- load polling targets from sqlite3 database 
  -- in this case webtrisul db 
  -- return { agent => [ifindex] } mappings 
  load_poll_targets = function(dbfile)

    T.log(T.K.loglevel.INFO, "Loading SNMP targets for polling from DB "..dbfile)


    local db=lsqlite3.open(dbfile)
    local stmt=db:prepare("SELECT name, value, value_ex_1, value_ex_2  FROM WEBTRISUL_OPTIONS WHERE value like 'snmp%' and id >= 10000");

	local targets = {} 

    while stmt:step()  do
      local v = stmt:get_values()

	  local ip = v[3]
	  local comm = v[4] 

	  targets[ #targets + 1] = { agent_ip = ip, agent_community = comm } 
    end
    stmt:finalize()


    -- community string     
    local stmt2=db:prepare("SELECT value FROM WEBTRISUL_OPTIONS where name='default_snmpv2_community';");
    if stmt2:step() then 
      T.default_community = stmt2:get_value(0)
    else 
      T.default_community = 'public'
    end 
    stmt2:finalize()

    db:close()

	return targets

  end, 

}

