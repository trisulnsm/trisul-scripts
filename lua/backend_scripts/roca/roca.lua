--
-- ROCA.lua 
--
-- TYPE:        BACKEND SCRIPT
-- PURPOSE:     Trisul LUA script to test SSL Certs for CVE-2017-15361 (ROCA
-- DESCRIPTION: A port of https://github.com/crocs-muni/roca to LUA 
--              You can put this script in the ../local-lua directory 
--              and Trisul will generate an alert whenever a match is found 
-- 
-- local dbg=require'debugger'



-- We need BIGNUM support - FFI to the rescue Setup LUAJIT2.1 FFI into libcrypto.so
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
  int BN_is_bit_set(const BIGNUM *a, int n);
  void BN_clear_free(BIGNUM *a);
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


  -- onload() load up the big numbers used to match 
  --
  onload = function() 

    -- Load bignums for the fingerprinting algorithm 
    local small_primes = { 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 
     61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 
     131, 137, 139, 149, 151, 157, 163, 167 }

    local markers = { "6", "30", "126", "1026", "5658", "107286", "199410", "8388606", "536870910",
      "2147483646", "67109890", "2199023255550", "8796093022206", "140737488355326", "5310023542746834",
      "576460752303423486", "1455791217086302986", "147573952589676412926", "20052041432995567486", 
      "6041388139249378920330", "207530445072488465666", "9671406556917033397649406", 
      "618970019642690137449562110", "79228162521181866724264247298",
      "2535301200456458802993406410750", "1760368345969468176824550810518", 
      "50079290986288516948354744811034", "473022961816146413042658758988474", 
      "10384593717069655257060992658440190", "144390480366845522447407333004847678774",
      "2722258935367507707706996859454145691646", "174224571863520493293247799005065324265470", 
      "696898287454081973172991196020261297061886", "713623846352979940529142984724747568191373310", 
      "1800793591454480341970779146165214289059119882", "126304807362733370595828809000324029340048915994", 
      "11692013098647223345629478661730264157247460343806",
      "187072209578355573530071658587684226515959365500926" } 

    -- Load the two primes arrays as BIGNUMS 
    T.bn_small_primes = {}
    for _,inum  in ipairs(small_primes) do
      local one=ffi.new("BIGNUM *[1]");
      C.BN_dec2bn(one,tostring(inum));
      T.bn_small_primes[#T.bn_small_primes+1]=one
    end 

    T.bn_markers = {}
    for _,snum  in ipairs(markers) do
      local one=ffi.new("BIGNUM *[1]");
      C.BN_dec2bn(one,snum);
      T.bn_markers[#T.bn_markers+1]=one
    end 

  end,


  -- is_vulnerable() accepts a RSA Public Key Modulus as a HEX string
  -- and tells you if it is vulnerable to ROCA or not 
  is_vulnerable = function( rsa_modulus_hex)

    local bn_remainder=ffi.new("BIGNUM[1]");
    local bn_modulus=ffi.new("BIGNUM*[1]");
    local nlen=C.BN_hex2bn(bn_modulus,rsa_modulus_hex);
        

    local  ctx = C.BN_CTX_new()
    for i,bn_p in ipairs(T.bn_small_primes) do

      C.BN_div(nil, bn_remainder, bn_modulus[0], bn_p[0], ctx)

      local rem = tonumber(ffi.string(C.BN_bn2dec(bn_remainder[0])))
      local is_set = C.BN_is_bit_set(T.bn_markers[i][0], rem)
      if is_set==0 then 
        C.BN_CTX_free(ctx)
        C.BN_clear_free(bn_modulus[0])
        return false 
      end 
    end 

    C.BN_CTX_free(ctx)
    C.BN_clear_free(bn_modulus[0])
    return true;
  end, 


  -- FTS Monitor : This script type plugs into the Trisul Full Text stream 
  -- and selects the sub-stream "SSL Certs" 
  fts_monitor  = {

    -- attach to the FTS/SSL Certs stream 
    fts_guid = function()  
      return T.ftsgroups['SSL Certs']
    end, 

    -- a new doc passing by stream , the doc is in canonical OpenSSL format 
    -- See Trisul LUA FTS documentation 
    onnewfts  = function(engine, fts )

      local certchain = fts:text()

      -- check each certificate in the chain for vulnerability 
      for m in certchain:gmatch("Modulus:([0-9a-fA-F:%s]*)Exponent") do

        local h = m:gsub("[:%s]","") 
        print("--match--"..h)

        if TrisulPlugin.is_vulnerable(h) then
          T.log("Found a PUBLIC KEY vulnerable to CVE2017-15361 ROCA"..fts:flow():id() .."  adding an alert")
          engine:add_alert("{B5F1DECB-51D5-4395-B71B-6FA730B772D9}" ,             -- {B51.. = user alerts 
                            fts:flow():id(),                                      -- flow id   
                            "ROCA",                                               -- alert type (sigid)
                            1,                                                    -- HIGH priority
                            "RSA Modulus in Cert vuln to ROCA. "..m:sub(1,90) );  -- message 
        else
          print("NOT VULNERABLE..")
        end 

      end

    end,

  },
}
