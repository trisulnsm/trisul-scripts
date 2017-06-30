--
-- ssh-spy
--
-- TYPE:        FRONTEND SCRIPT
-- PURPOSE:     Hook into Trisul's TCP reassembly engine 
-- DESCRIPTION: Tag ssh session with KE + Enc + HMAC algorithm 
-- 


local PDURecord = require'pdurecord'

TrisulPlugin = { 

  -- the ID block, you can skip the fields marked 'optional '
  -- 
  id =  {
    name = "ssh-spy",
    description = "SSH KE/Crypto/HMAC tracker",
  },


  onload  = function()
  	T.PDUStreamers = {} 


  end,


  -- reassembly_handler block
  -- 
  reassembly_handler   = {

    -- we indicate to Trisul we want ssh only (in trisul key format that is p-0016) 
    -- port 22 in hex
    filter = function(engine, timestamp, flowkey) 
        return flowkey:id():match("p-0016")  ~= nil 
    end,



	onnewflow = function(engine, timestamp, flowkey) 

        if flowkey:id():match("p-0016")  == nil then return; end

		local ins =   PDURecord.new(flowkey:id() ,0);
		local outs =   PDURecord.new(flowkey:id() ,1);

		ins:want_to_pattern("\r\n")
		outs:want_to_pattern("\r\n")
	
		T.PDUStreamers[flowkey:id()] = {  ins, outs }
	end,



    -- WHEN CALLED: when a chunk of reassembled payload is available 
    --  
    -- see note for why we check the flowkey again , to co-operate with other reassembly scripts
    onpayload = function(engine, timestamp, flowkey, direction, seekpos, buffer) 

        if flowkey:id():match("p-0016")  == nil then return; end

		local pdur = T.PDUStreamers[flowkey:id()][direction]

		pdur:push_chunk(seekpos, buffer:tostring())

    end,

  }
}
