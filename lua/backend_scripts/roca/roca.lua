--
-- ROCA.lua 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Check RSA Modulus for signature match 
-- DESCRIPTION: 
-- 
-- local dbg=require'debugger'


-------------------------------------------------------------------------------
-- Setup LUAJIT2.1 FFI into libcrypto.so
-- We are going to use the SHA256 streaming mode from libcrypto 
-- 
local ffi=require('ffi')
local C = ffi.load('crypto')

ffi.cdef[[

 typedef unsigned long  BN_ULONG;

 struct bignum_st
        {
        BN_ULONG *d;    /* Pointer to an array of 'BN_BITS2' bit chunks. */
        int top;        /* Index of last used d +1. */
        /* The next are internal book keeping for bn_expand. */
        int dmax;       /* Size of the d array. */
        int neg;        /* one if the number is negative */
        int flags;
        };

 typedef struct bignum_st BIGNUM;
 
 typedef struct bignum_ctx BN_CTX;
 

 char *BN_bn2hex(const BIGNUM *a);
 char *BN_bn2dec(const BIGNUM *a);
 int BN_hex2bn(BIGNUM **a, const char *str);
 int BN_dec2bn(BIGNUM **a, const char *str);
 int BN_div(BIGNUM *dv, BIGNUM *rem, const BIGNUM *a, const BIGNUM *d, BN_CTX *ctx);

 BN_CTX *BN_CTX_new(void);
 void BN_CTX_free(BN_CTX *c);


]]
-- End setup FFI into libcrypto 
-------------------------------------------------------------------------------



TrisulPlugin = { 

  id =  {
    name = "ROCA Checker",
    description = "Run a simple signature test on the RSA Modulus",
  },

  onload = function() 

   T.first_20_primes = { 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 
               97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167 }

  end,



  fts_monitor  = {

    -- attach to the FTS/SSL Certs stream 
    fts_guid = function()  
      return T.ftsgroups['SSL Certs']
    end, 



    -- a new doc passing by stream 
    onnewfts  = function(engine, fts )

      local certchain = fts:text()


	  for m in certchain:gmatch("Modulus:([0-9a-fA-F:%s]*)Exponent") do

	    local bn_modulus=ffi.new("BIGNUM * [1]");

		local h = m:gsub("[:%s]","") 
	  	print("--match--"..h)


		local nlen =  C.BN_hex2bn(bn_modulus,h);

		-- print("PRINTED = ".. ffi.string(C.BN_bn2dec(bn_modulus[0])))

		local  ctx = C.BN_CTX_new()

	    local bn_rem=ffi.new("BIGNUM[1]");

	    local bn_small_prime=ffi.new("BIGNUM *[1]");
		C.BN_dec2bn(bn_small_prime,"17");

		C.BN_div(nil, bn_rem, bn_modulus[0], bn_small_prime[0], ctx)

		print("REMAINDER = ".. ffi.string(C.BN_bn2dec(bn_rem[0])))



	  end

    end,

  },
}
