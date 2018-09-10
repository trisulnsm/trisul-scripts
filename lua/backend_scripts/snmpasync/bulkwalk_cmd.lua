-- return { key, value } 
function do_bulk_walk( agent, version, community, oid  )
  command = "snmpbulkwalk"
  if version == "1" then command="snmpwalk" end
  local tstart = os.time()
  local ofile = os.tmpname() 
  os.execute(command.." -r 1 -O q -t 3  -v"..version.." -c '"..community.."' "..agent.."  "..oid.. " > "..ofile)
  --print(command.." -r 1 -O q -t 3  -v"..version.." -c '"..community.."' "..agent.."  "..oid)

  local ret = { } 
  local h=io.open(ofile)
  for oneline in h:lines()
  do
    local  k,v = oneline:match("%.(%d+)%s+(.+)") 
	if k then 
		ret[agent.."_"..k] = v:gsub('"','')
	else
		print("ERROR in snmp output line="..oneline)
	end 
  end 
  h:close()
  os.remove(ofile)

  print("Done with agent "..agent.." elapsed secs="..os.time()-tstart)
  return ret
end

