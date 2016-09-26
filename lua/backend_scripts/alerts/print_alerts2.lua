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

		-- demonstrates how you can either return a GUID string directly or
		-- return a function that will return a GUID string. 
		-- 
		-- if you knew the GUID for External IDS alert group you could have 
		-- simply done 
		--
		--  alert_guid = '{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}',
		-- 
		alert_guid = function()
			for name ,guid in pairs(T.alertgroups) do 
				if name:match("External IDS") then return guid; end
			end
		end,

		-- a new alert was seen - print all details to screen 
		-- 
		onnewalert = function(engine,alert)


			print("------------ new alert ------------------")
			print("timestamp         "..  alert:timestamp())
			print("date and time     "..  os.date('%c', alert:timestamp()))
			print("source_ip         "..  alert:source_ip())
			print("source_port       "..  alert:source_port())
			print("dest ip           "..  alert:destination_ip())
			print("dest port         "..  alert:destination_port())
			print("sigid             "..  alert:sigid())
			print("class             "..  alert:classification())
			print("priority          "..  alert:priority())
			print("message           "..  alert:message())
			print("extramsg          "..  alert:extra_message())
			print("status            "..  alert:status())
			print("ack               "..  alert:ack_flag())
			print("flow              "..  alert:flow():to_s())
			print("-----------------------------------------")

		end,

	}
	
}
