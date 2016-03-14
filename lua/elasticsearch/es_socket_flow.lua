-- .lua
--
--[=====[
  * es_socket_flow.lua
  * Monitors session group (flow) activity 
  * Send the document(flow record)  to elasticsearch using elasticsearch-lua plugin
    - https://github.com/DhavalKapil/elasticsearch-lua
  * elasticsearch-lua uses luasocket for  communication with elasticsearch
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
  	print("LOADED : es_socket_flow.lua ")
    package.path=package.path..";/home/devbox/sware/elasticsearch-lua-master/src/?.lua"
    -- default parameters to connect elasticsearch
    local protocol = "http";
    local host = "localhost";
    local port = 9200;
    T.es = require 'elasticsearch'
    T.client = T.es.client{
      hosts = {
        protocol = protocol,
        host = host,
        port = port
      }
    }
   --[=====[ 
    * check elasticsearch indices exists?
    *  if not exists create and map properties 
       -- You can use date property to create time-based events in kibana(metafields)
   --]=====]
   -- Indices
   local indices = T.client.indices:new();
   data,err = indices:exists({index="trisul"})
   if err==nil then
    data,err = indices:create{
      index="trisul",
      type="flows",
      body={
        mappings= {
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
    }
   end

  end,

  onunload = function()
  	print("BYE: es_socket_flow.lua ")
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
  -- date used for time-based events in kibana
  local st,et = sess:time_window();
  local data, err = T.client:index{
    index = "trisul",
    type = "flows",
    body = {
     date=os.time()*1000,
     protocol=sess:flow():protocol(),
     source_ip=sess:flow():ipa_readable(),
     source_port=sess:flow():porta_readable(),
     dest_ip=sess:flow():ipz_readable(),
     dest_port=sess:flow():portz_readable(),
     fwd_bytes=sess:az_bytes(),
     rev_bytes=sess:za_bytes(),
     total_bytes=sess:za_bytes()+sess:az_bytes(),
     start_time=st*1000,
     end_time=et*1000,
     duration=et-st
   }
  }
	end,

	onendflush = function(dbengine)
    print("*** END  FLUSH ")
	end,

  onnewflow = function(dbengine, sess)

  end,

  },

}

