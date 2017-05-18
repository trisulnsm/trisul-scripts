rev-ssh.lua 
==============

SSH Tunnels are really problematic in a number of ways as described in this blog post [Detecting SSH Tunnels](https://trisul.org/blog/reverse-ssh/post.html). In that we mention that it is possible to perform traffic analysis of SSH Tunnels to detect them. 

*This is an adaptation of the Bro script originally written by John B Stackhouse III. The scripts are available at https://github.com/darkphyber/bro*


You can think of Trisul roughly as Bro but with LUA and an emphasis on traffic metering and streaming analytics.  The LUA API lets you hook into [TCP reassembly](https://trisul.org/docs/lua/reassembly.html) , [HTTP file extraction](https://trisul.org/docs/lua/fileextractoverview.html), and a number of other [points](https://trisul.org/docs/lua/basics.html)



The "reassembly" script type
----------------------------

Here is what we are going to need for the task.

1. a way to get reassembled SSH packets 
2. a framework to count and alert when triggered. 

Of the 16 different script types if Trisul we find the [reassembly handler](https://www.trisul.org/docs/lua/reassembly.html) script type is perfectly suited for this purpose.  Next you can just copy a [skeleton reassembly script](https://github.com/trisulnsm/trisul-scripts/tree/master/lua/skeletons) and start filling out the functions you need.  


#### How this script works

_onpayload_ is called when a chunk of reassembled data is available in any direction. We use this to maintain a state for each SSH flow and trigger when we see the pattern

````lua

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
````


When you see a reassembled payload of 76 bytes you update a state machine, any other packet size resets it. 

````lua

    if buffer:size() == MAGIC_SEGMENT_LENGTH then
      sshF.hits[direction] =  sshF.hits[direction] + 1
      sshF.seekpos[direction]=seekpos;
    else
      sshF.hits[0] =  0
      sshF.hits[1] =  0
      sshF.seekpos[direction]=seekpos;
    end
````


A few things to note 

#### 1. Why check again for SSH protocol. 

The way Trisul's [co-operative scripting](https://trisul.org/docs/lua/reassembly.html#function_onpayload)  works is if you have another script that expresses interest in a different flow, then all scripts get it.  So even though in the @filter@ method you said you only want SSH flows, you may still get others if other scripts ask for it. 

````lua
if flowkey:id():match("p-0016")  == nil then return; end
````

#### 2. More complex detection of segment lengths   

The SSH Tunnel packet lengths vary due to the HMAC algorithm and the encryption used. You can update the script here  or even use multiple packet sizes and make the detection more sophisticated to catch all HMAC algorithsma and encryption combinations  '

_( Its is just plain LUA !)_

````
local MAGIC_SEGMENT_LENGTH  =  76
local CHARACTERS_TRIGGER = 3
local MIN_ALERT_INTERVAL_SECS = 300 
````

####. 3. Single seek pointer for all scripts 

If you notice we are also maintaining a 'seek position ' as part of the flow state. This again has to do with co-operative handling of multiple scripts. There is only one seek position per flow per direction for all reassembly scripts to share. So it is possible you get double-called for the same segment. The seek position will move only when all scripts move it.

````
if sshF.seekpos[direction]==seekpos then
  return -- no new data 
end
````

