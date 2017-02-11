-- eve_unixsocket.lua
--
-- same as eve.json file but uses Unix Sockets (via Luajit FFI) 
--
-- 

local ffi=require'ffi'

-- need to do this mapping .. :-(
-- takes time to get used to LuaJIT FFI but quite easy once you get the 
-- hang of it 
ffi.cdef[[

typedef int   ssize_t;
static const uint8_t  AF_UNIX=1;
static const uint8_t  SOCK_DGRAM=2;
typedef uint16_t sa_family_t;
typedef uint32_t socklen_t;

struct constants {
  static const int AF_UNIX=1;
  static const int AF_INET=2;
  static const int SOCK_DGRAM=2;     /* socket.h        */
  static const int MSG_DONTWAIT=0x40;  /* socket_type.h   */
};

int     socket(int domain, int type, int protocol);

struct sockaddr {
  sa_family_t sa_family;          
  char        sa_data[14];       
};

struct sockaddr_un {
    sa_family_t   sun_family;      
    uint8_t  sun_path[108];  
};

int bind(int socket, const struct sockaddr *, socklen_t addrlen) ;
ssize_t recv(int socket, void * buf, size_t buflen, int flags);
size_t strlen(const char * s);
char * strerror(int errno);
int unlink(char * pathname);
]] 


local K = ffi.new("struct constants");


-- socket 
local socket = ffi.C.socket( K.AF_UNIX, K.SOCK_DGRAM, 0);
if  socket == -1 then 
  print("Error socket() " .. strerror())
  return 
end 

local strerror = function()
  return ffi.string(ffi.C.strerror( ffi.errno() ))
end


-- bind to unix socket endpoint
local addr = ffi.new("struct sockaddr_un");
addr.sun_family = K.AF_UNIX;
addr.sun_path = "/tmp/snort_alert"
ffi.C.unlink(addr.sun_path);
local ret = ffi.C.bind( socket,  ffi.cast("const struct sockaddr *", addr) , ffi.sizeof(addr));


print ("Ret = "..ret.." pah="..ffi.string(addr.sun_path) )
if ret == -1 then
  print("Error bind() " .. strerror())
  return
end



