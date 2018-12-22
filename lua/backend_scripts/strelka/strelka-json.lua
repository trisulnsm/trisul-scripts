--
-- engine_monitor.lua - tail all the strelka JSON and push into Trisul using add_resource()

local JSON=require'JSON'
local STRELKADIR='/var/log/strelka'

TrisulPlugin = { 

  -- id block 
  --
  id =  {
    name = "Strelka JSON",
    description = "Feedback JSON scan results back into trisul", 
  },


  onload = function()
    fhandles = {} 
  end, 


  -- engine_monitor block - called every minute for each backend engine 
  --                        during stream window closing 
  engine_monitor  = {

    -- WHEN CALLED: before starting a streaming flush operation 
    -- called by default every 60 seconds per engine (default 2 engines)
    -- use engine:instanceid() to get the engine id 
    -- 
    onbeginflush  = function(engine, timestamp )

      if engine:instanceid() ~= "0" then return end

      -- refresh the logs 
      local pdirs  = io.popen("ls "..STRELKADIR.."/*.log")
      local dirstr = pdirs:read("*a")
      pdirs:close()

      -- use to track rollover files 
      local g=timestamp

      -- all the .log files in /var/log/strelka
      for fn in dirstr:gmatch("(%S+.log)") do
        local hh  = fhandles[fn]
        if not hh then
          hh = {
            generation = g,
            handle = io.open( fn, "r")
          }
          fhandles[fn]=hh
          print("Opened new file: "..fn)
        else
          hh.generation=g
        end
      end

      -- if files closed by writer, or compressed delete 
      for k,v in pairs(fhandles) do
        if v.generation ~= g then 
          v.handle:close() 
          fhandles[k]=nil
          print("Deleted file")
        end
      end

      -- read the latest JSON from each file and push into Trisul
      -- here you can do some filtering or enrichment 
      -- TODO: we just push the entire scan results for all docs, can do better
      for k,v in pairs(fhandles) do

        local jstr = v.handle:read("*l") 
        while  jstr do 
          local fp = JSON:decode(jstr)
          local pretty = JSON:encode_pretty(fp)

          engine:add_resource( "{8A3E3EE5-0194-4B3C-9400-39BE9E7F7A11}",
            "06A:00.00.00.00_p-0000:00.00.00.00_p-00000",
            "Strelka File Scan Output",
            pretty)
            
          jstr = v.handle:read("*l")
        end

        print("Finished file: " ..  k)
      end

     end,

  },

}
