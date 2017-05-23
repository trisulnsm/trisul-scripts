--
-- rev-ssh.lua skeleton
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Hook into Trisul's TCP reassembly engine 
-- DESCRIPTION: Check for reverse SSH 
-- 


TrisulPlugin = { 


  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "Rev ssh ",
    description = "check for rev ssh by single key press length ",
  },


  onload = function()
      T.SshFlowTable = {} 
  end,


  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- we indicate to Trisul we want ssh only (in trisul key format that is p-0016) 
    -- port 22 in hex
    filter = function(engine, timestamp, flowkey) 
        return flowkey:id():match("p-0016")  ~= nil 
    end,


    -- found a new flow ; setup a control structure to track keypress
    onnewflow = function(engine, timestamp, flowkey)

        if flowkey:id():match("p-0016")  == nil then return; end  

        T.SshFlowTable[ flowkey:id() ] = {
          seekpos ={[0]=0,[1]=0},
          hits ={[0]=0,[1]=0},
          lastalertts=0,
        }

    end,

    -- flow terminated ; free up LUA lookup
    onterminateflow = function(engine, timestamp, flowkey)

        if flowkey:id():match("p-0016")  == nil then return; end  

        T.SshFlowTable[ flowkey:id() ] = nil
    end,


    -- WHEN CALLED: when a chunk of reassembled payload is available 
    --  
    -- see note for why we check the flowkey again , to co-operate with other reassembly scripts
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

        if flowkey:id():match("p-0016")  == nil then return; end

        local MAGIC_SEGMENT_LENGTH  =  76
        local CHARACTERS_TRIGGER = 3
        local MIN_ALERT_INTERVAL_SECS = 300 

        local sshF = T.SshFlowTable[ flowkey:id() ] 

        if sshF.seekpos[direction]==seekpos then
          return -- no new data 
        end

        if buffer:size() == MAGIC_SEGMENT_LENGTH then
          sshF.hits[direction] =  sshF.hits[direction] + 1
          sshF.seekpos[direction]=seekpos;
        else
          sshF.hits[0] =  0
          sshF.hits[1] =  0
          sshF.seekpos[direction]=seekpos;
        end

        -- print("Payload length for session "..flowkey:id().. "direction = ".. direction.." bufsz=".. buffer:size() .. " seekpos = "..seekpos )
        if sshF.hits[0] >= CHARACTERS_TRIGGER and sshF.hits[1] >= CHARACTERS_TRIGGER then

          sshF.hits[0] =  0
          sshF.hits[1] =  0

          if timestamp-sshF.lastalertts<MIN_ALERT_INTERVAL_SECS then
            T.log("Found Rev SSH "..flowkey:to_s().." but not alerting due to threshold interval")
          else
            T.log("Found Rev SSH "..flowkey:to_s().." ALERTING and TAGGING flow")
          
            -- tag flow 
            engine:tag_flow(flowkey:id(),"REVSSH");

            -- alert 
            engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}", flowkey:id(),"REVSSH",1,"rev ssh detected by keypress detect method");

            sshF.lastalertts=timestamp
          end
        end

    end,



  }

}
