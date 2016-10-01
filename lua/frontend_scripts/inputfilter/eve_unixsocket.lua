-- eve_unixsocket.lua
--
-- same as eve.json file but uses Unix Sockets (via Luajit FFI) 
--
-- 


local ffi=require'ffi'

ffi.cdef[[

typedef int   ssize_t;
static const uint8_t  AF_UNIX=1;
static const uint8_t  SOCK_DGRAM=2;

int     socket(int, int, int);

struct sockaddr {
	sa_family_t sa_family;          
	char        sa_data[14];       
};

struct sockaddr_un {
    uint8_t  sun_family;      
    uint8_t  sun_path[108];  
};

int bind(s, struct sockaddr *, int) ;
ssize_t recv(int, void *, size_t, int);

]] 
