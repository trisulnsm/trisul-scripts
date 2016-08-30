-- print_alerts.lua
--
-- doesnt do much , just prints all alert details to screen
-- 
-- Run Trisul in "nodemon" (note its not nodaemon ! ) mode so 
-- the terminal is available for printing
--
--    "trisulctl_probe testbench run <pcap_file>" should do it 
-- 

TrisulPlugin = {

	id =  {
		name = "alert printer",
		description = "sample to just print alerts"
	},


	alert_monitor  = {

	    alert_guid = '{5E97C3A3-41DB-4e34-92C3-87C904FAB83E}',

		-- a new alert was seen - print all details to screen 
		-- 
		onnewalert = function(engine,alert)


			print("timestamp "..  alert:timestamp())
			print("date and time "..  os.date('%c', alert:timestamp()))
			print("source_ip "..  alert:source_ip())
			print("source_port "..  alert:source_port())
			print("dest ip "..  alert:destination_ip())
			print("dest port "..  alert:destination_port())
			print("sigid "..  alert:sigid())
			print("class "..  alert:classification())
			print("priority "..  alert:priority())
			print("message "..  alert:message())

		end,

	}
	
}
