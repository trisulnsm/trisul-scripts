-- .lua
--
--[=====[
  * es_flow_flow.lua
  * Monitors session group (flow) activity 
  * Send the document(flow record)  to elasticsearch using curl
  * curl tool is used for communication with elasticsearch
--]=====]
--
TrisulPlugin = {

  id = {
    name = "Demo From Group Monitor",
    description = "Monitors all session(flow) group activity ",
    author = "Unleash",
    version_major = 1,
    version_minor = 0,
  },


  onload = function()
    print("LOADED : es_curl_flow.lua ")
    local protocol = "http";
    local host = "localhost";
    local port = 9200;
    --[=====[
    * check elasticsearch indices exists?
    *  if not exists create and map properties
       -- You can use date property to create time-based events in kibana(metafield)
    --]=====]
    -- Indices
    T.json = require 'JSON'
    T.uri = protocol.."://"..host..":"..port.."/trisul"
    local h = io.popen("curl -XHEAD -I '"..T.uri.."' 2>/dev/null")
    if not h:read("*a"):match("200 OK") then
      local mappings = { 
        mappings={
          flows={
            properties={
              date={
                type="date"
              },
              start_time={
                type="date"
              },
              end_time={
                type="date"
              },

            }
          }
        }
       }
      local h = io.popen("curl -X PUT '"..T.uri.."'".." -H 'Content-Type: application/json' -d'"..T.json:encode(mappings).."' 2>/dev/null")
    end
    T.uri = T.uri.."/flows"
  end,


  onunload = function()
    print("BYE: es_curl_flow.lua ")
  end,

  -- 
  -- Monitor attaches itself to a counter group and gets called for
  -- all keys matching the regex 
  --
  sg_monitor  = {

  session_guid  =  '{99A78737-4B41-4387-8F31-8077DB917336}',
        

  onbeginflush = function(dbengine,t) 
    print("*** BEGIN FLUSH engine="..dbengine:instanceid() )
  end,

  onflush= function(dbengine, sess)
    local flow ={};
    local st,et = sess:time_window();
    flow["date"]=os.time()*1000;
    flow["protocol"]=sess:flow():protocol();
    flow["source_ip"]=sess:flow():ipa_readable();
    flow["source_port"]=sess:flow():porta_readable();
    flow["dest_ip"]=sess:flow():ipz_readable();
    flow["dest_port"]=sess:flow():portz_readable();
    flow["fwd_bytes"]=sess:az_bytes();
    flow["rev_bytes"]=sess:za_bytes();
    flow["total_bytes"]=sess:za_bytes()+sess:az_bytes();
    flow["start_time"]=st*1000;
    flow["end_time"]=et*1000;
    flow["duration"]=et-st;
    local h = io.popen("curl -X POST -i '"..T.uri.."' -H 'Content-Type: application/json' -d '" ..T.json:encode(flow).."' 2>/dev/null")
  end,

  onendflush = function(dbengine)
    print("*** END  FLUSH ")
  end,

  onnewflow = function(dbengine, sess)

  end,

  },

}
