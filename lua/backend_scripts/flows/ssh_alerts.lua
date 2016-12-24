-- ssh_alerts.lua
-- 
--  monitor flows being flushed - then generate an alert if there is > 15K on each side 
--  this could indicate a successful SSH session 
--
--  Also create a new alert group called SSH alerts use that to push it and also push it 
--  to the External IDS alert group 
--
-- 
TrisulPlugin = {

	id =  {
		name = "SSH alerts", 
		description = "When successful SSH happens (simple version)",
	},

	alertgroup = {
		guid = '{0409EAC7-1E60-43D3-C0FA-A87429F99728}',	
		name = 'SSH Alerts',
		description = 'Alerts on SSH login and transfer'
	},

	sg_monitor  = {

		onnewflow = function(engine, newflow)

			-- p-0016 appears in flowkey format when ssh involved
			-- you can also newflow:flow():porta_readable() = '22' (for port 22) etc
			local flowkey = newflow:flow():id()

			if flowkey:match("p-0016") then 

				print("On engine "..engine:instanceid().." found ssh session " .. newflow:flow():to_s());

				local total_bytes =  newflow:az_bytes() + newflow:za_bytes()

				if total_bytes > 30000 then
					engine:add_alert('{0409EAC7-1E60-43D3-C0FA-A87429F99728}',
									 newflow:flow():id(),
									 'SSHXFER',
									 1,
									 "ssh session transferring ".. total_bytes.." bytes, check it out");
				end 

			end
		end,


	},

}
