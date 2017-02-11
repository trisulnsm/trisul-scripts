-- tls-heartbleed.lua
--
-- Detects TLS heartbeats 
--  simple method - if HB resp size != req size
--  take advantage of RFC 6520 that limits inflight heartbeats to 1 
--  alert if you see a heartbeat  mismatch 
-- 
-- content types in 
-- http://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#tls-parameters-5
--
-- Remember -> you cant look inside the heartbeat (it is encrypted) 
-- 

TrisulPlugin = {

  id = {
    name = "TLS Heartbleed ",
    description = "Log req/resp in one line ",
    author = "trisul-scripts", version_major = 1, version_minor = 0,
  },

  onload = function()
    pending_hb_requests = { } 
  end,


  reassembly_handler  = {

    onattribute = function(engine,flow,timestamp, nm, valbuff)

      if nm == "TLS:RECORD" then
        local  content_type = valbuff:hval_8(0)

        -- heartbeats have content_type (unencrypted always as 24)
        if content_type == 24 then
          local req_len  = pending_hb_requests[flow:id()]

          -- found pending inflight request, compare sizes and alert 
          -- on mismatch
          if req_len ~= valbuff:size()  then

            -- this is how you add an alert to Trisul 
            engine:add_alert_ids( 
              "{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}", -- GUID for IDS 
              flow:id(),                                -- flow 
              "sid-8000002",                            -- a sigid (private range)
              "trisul-lua-gen",                         -- classification
              1,                                        -- priority 1, 
              "Possible heartbleed situation ")         -- message 

          end
          pending_hb_requests[flow:id()] = nil 
        else
          -- save size of inflight  TLS hb request 
          pending_hb_requests[flow:id()] = valbuff:size()
        end

      elseif  nm == "^D" then 
        -- ^D is sent when a connection closes 
        -- connection closed, free up map so it can be garbage collected 
        pending_hb_requests[flow:id()]=nil 
      end

    end,
  },

}
