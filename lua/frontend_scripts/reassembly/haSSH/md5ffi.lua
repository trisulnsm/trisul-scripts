-- Setup LUAJIT2.1 FFI into libcrypto.so for MD5 
local ffi=require('ffi')

local status,C
for _,lib in ipairs( {'libcrypto.so.1.0.2k', 'libcrypto.so.1.0.0'} )
do
  status, C = pcall(function() return  ffi.load(lib) end)
  if status then break end 
end
if not status then error "Cant load FFI libcrypto version " end

-- local dbg=require'debugger'
ffi.cdef[[
  typedef struct MD5state_st
  {
    unsigned int A,B,C,D;
    unsigned int Nl,Nh;
    unsigned int data[16];
    unsigned int num;
  } MD5_CTX;
  int MD5_Init(MD5_CTX *c);
  int MD5_Update(MD5_CTX *c, const void *data, size_t len);
  int MD5_Final(unsigned char *md, MD5_CTX *c);
]]

-- ffi based MD5 
function md5sum( input)
  local hashresults = ffi.new("uint8_t[16]")
  ctx = ffi.new'MD5_CTX'
  C.MD5_Init(ctx)
  C.MD5_Update(ctx,input,#input)
  C.MD5_Final(hashresults,ctx)
  return T.util.bin2hex(ffi.string(hashresults,16)) 
end 

