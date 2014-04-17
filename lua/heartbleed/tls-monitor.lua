-- tls-monitor.lua
--
-- A new countergroup with 1 meter. Monitors TLS record types seen 
-- on wire. (All except Application Data) 
--
-- 
-- Meter 0 =  Number of records  
--
TrisulPlugin = {

  id = {
    name = "TLS Record",
    description = "Count SSL/TLS record types ",
    author = "Unleash", version_major = 1, version_minor = 0,
  },

  countergroup = {
    control = {
      guid = "{fc970d3a-5a39-4e31-a687-672c5174a58e}",
      name = "TLSRec", description = "Record types", bucketsize = 30,
    },

    meters = {
        {  0, T.K.vartype.COUNTER,   10, "Hits", "Hits",    "hits" },
    },  

    keyinfo = {
      {"14/00","change_cipher_spec"},
      {"15/00","alert"},
      {"16/00","hello_request"},
      {"16/01","client_hello"},
      {"16/02","server_hello"},
      {"16/03","hello_verify_request"},
      {"16/04","NewSessionTicket"},
      {"16/0B","certificate"},
      {"16/0C","server_key_exchange"},
      {"16/0D","certificate_request"},
      {"16/0E","server_hello_done"},
      {"16/0F","certificate_verify"},
      {"16/10","client_key_exchange"},
      {"16/14","finished"},
      {"16/15","certificate_url"},
      {"16/16","certificate_status"},
      {"16/17","supplemental_data"},
      {"17/00","application_data"},
      {"18/00","heartbeat"},
    }

  },

 
  flowmonitor  = {

    onflowattribute = function(engine,flow,timestamp, nm, valbuff)

      if nm == "TLS:RECORD" then
        local content_type = valbuff:hval_8(0)
        local handshake_type = 0

        if content_type == 22 then
          -- heuristic check if encrypted 
          handshake_type = valbuff:hval_8(5)
          local hslen = valbuff:hval_24(6)
          if hslen > valbuff:size() or  handshake_type >= 24  then 
            handshake_type=0
          end
        end

        -- keys look like "16/02"
        local keystr = string.format("%02x/%02X", content_type , handshake_type)

        engine:update_counter("{fc970d3a-5a39-4e31-a687-672c5174a58e}", 
                            keystr, 0, 1)

      end
       
      end,

  },


}

