-- socialalert.lua
--  
--  Generates an ALERT when you access Facebook/Twitter 
--
--  Sample demonstrates  the following
--
--  1.   We use the O and CN attributes in TLS Certs 
--  2.   Use of the T.re2(..) regex engine 
--  3.   Generating a full alert that adds to Snort/Suricata alert streams
--
--
TrisulPlugin = {

	id = {
		name = "Social Media Alerter",
		description = "Alerts when we see social media traffic (sample) ",
		author = "GithubRepo",
		version_major = 1,
		version_minor = 0,
	},

	--
	-- we initialize a Google RE2 engine here to precompile the REGEX 
	-- 
	-- T.re2(..regex..) 
	--
	onload = function() 
		TrisulPlugin.k = T.re2("twitter|facebook")
		T.log("Initialized the regex to match twitter and facebook")
	end,


	reassembly_handler  = {
		-- 
		-- Called for each flow attribute, we ignore all except TLS:O 
		-- which is the Org/CN found in the certificate 
		--
		onattribute = function(engine,flow,timestamp,attribute_name,attribute_value)

			if attribute_name == "TLS:O" then

				local v = attribute_value:tostring():lower()

				if TrisulPlugin.k:partial_match( v) then 
					--
					-- add an alert if REGEX matches social media sites
					--
					engine:add_alert_ids( 
							"{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}", -- GUID for IDS 
							flow:id(),                                -- flow 
							"sid-8000001",                            -- a sigid (private range)
							"lua-social",                             -- classification
							1,                                        -- priority 1, 
							"Detected social media usage")            -- message 
				end
			end
		end,
	}
}

