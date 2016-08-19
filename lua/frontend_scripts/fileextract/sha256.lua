--
-- sha256 hash
--	How you can integrate custom hashes into the Trisul LUA File Reconstruction Framework

--  We use the streaming contents to update the hash, rather than wait for full files 
-- 

-------------------------------------------------------------------------------
-- Setup LUAJIT2.1 FFI into libcrypto.so
-- We are going to use the SHA256 streaming mode from libcrypto 
-- 
local ffi=require('ffi')
local C = ffi.load('crypto')

ffi.cdef[[

	typedef struct SHA256state_st
	{
		unsigned int h[8];
		unsigned int Nl,Nh;
		unsigned int data[16];
		unsigned int num,md_len;
	} SHA256_CTX;

	int SHA256_Init(SHA256_CTX *c);
	int SHA256_Update(SHA256_CTX *c, const void *data, size_t len);
	int SHA256_Final(unsigned char *md, SHA256_CTX *c);

]]
-- End setup FFI into libcrypto 
-------------------------------------------------------------------------------


-- sha256.lua 
--
--	   the built in MD5 file hashing
--
TrisulPlugin = {

  id = {
    name = "generates SHA256 hashes ",
    description = "How to integrate streaming hash into Trisul LUA file extract",
  },


  onload = function() 

	T.hash_states = {}
  	T.hash_states[0]  = {}  -- flow_id => sha256  TCP OUT direction
  	T.hash_states[1]  = {}  -- flow_id => sha256  TCP IN  direction

  end,

  -- Monitor attaches itself to file extraction module(s)
  --
  filex_monitor  = {

  	-- save all content to /tmp/kk 
    --
	  onpayload_http = function ( engine, timestamp, flowkey, path, req_header, resp_header, dir, seekpos , buffer )

	  	-- print( buffer:hexdump())

		local ctx = T.hash_states[dir][flowkey:id() ]

		if ctx == nil then
			ctx = ffi.new'SHA256_CTX'
			C.SHA256_Init(ctx)
			T.hash_states[dir][flowkey:id() ]=ctx
		end

		if buffer:size() ==0 then 
			local hashresults = ffi.new("uint8_t[32]")
			C.SHA256_Final( hashresults, ctx)

			local hex_sha256 = T.util.bin2hex(ffi.string(hashresults,32)) 

			engine:add_resource('{9781db2c-f78a-4f7f-a7e8-2b1a9a7be71a}',  -- represents FileHash resource in Trisul 
								flowkey:id(),
								"SHA256:"..hex_sha256,
								path)

			T.hash_states[dir][flowkey:id() ] = nil

		else
			C.SHA256_Update(ctx, buffer:tostring(),buffer:size())
		end 


	  end,

	}

}

