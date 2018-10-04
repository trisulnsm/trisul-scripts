-- unsock_api.lua
--
-- Allows outside processes to call INTO the trisul engine by sending  
-- commands to a Unix Socket. Note this is contextless. You will simply
-- be sending API commands without anyone calling into your code.
-- 
-- Use case: If you have an outside process adding metrics or alerts into Trisul
--
-- This script plugs into the on_engineflush(..) backend script type 
--
-- The command structure is VERY simple designed for speed.
-- API commandname\narg1\narg2.. 
--
--

local ffi=require'ffi'
local API_SOCKETFILE_NAME='api.sock'
local dbg =require'debugger'

-- need to do this mapping .. :-(
-- takes time to get used to LuaJIT FFI but quite easy once you get the 
-- hang of it 
ffi.cdef[[

typedef int   ssize_t;
typedef uint16_t sa_family_t;
typedef uint32_t socklen_t;

struct constants {
    static const int AF_UNIX=1;
    static const int AF_INET=2;
    static const int SOCK_DGRAM=2;          /* socket.h        */
    static const int MSG_DONTWAIT=0x40;     /* socket_type.h   */
    static const int EAGAIN=11;     /* asm../errno.h */
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


strerror = function()
  return ffi.string(ffi.C.strerror( ffi.errno() ))
end

K = ffi.new("struct constants");

TrisulPlugin = {

  id = {
    name = "Trisul-API-Unixsocket",
    description = "Add metrics, alerts, metadata to Trisul by sending strings to a Unix socket",
  },


  -- returning false from onload will effectively stop the script itself
  -- 
  onload = function()

  	T.socket = nil 


  end,


  open_api_socket = function(socket_path ) 

    T.log(T.K.loglevel.INFO, "API Socket setting up the socket : ".. socket_path)

    -- socket 
    local socket = ffi.C.socket( K.AF_UNIX, K.SOCK_DGRAM, 0 );
    if  socket == -1 then 
      T.logerror("Error socket() " .. strerror())
      return  false 
    end 

    -- bind to unix socket endpoint
    local addr = ffi.new("struct sockaddr_un");
    addr.sun_family = K.AF_UNIX;
    addr.sun_path = socket_path
    ffi.C.unlink(addr.sun_path);
    local ret = ffi.C.bind( socket,  ffi.cast("const struct sockaddr *", addr) , ffi.sizeof(addr));

    if ret == -1 then
        T.logerror("Error bind() " .. strerror())
        return false
    end

    T.socket = socket

    -- single buffer into which Socket  msg is read 
    T.MAX_MSG_SIZE=256000;
    T.rbuf  = ffi.new("char[?]", T.MAX_MSG_SIZE);

	return true
   end,




	-- engine_monitor block
	--
	engine_monitor  = {

	-- WHEN CALLED: before starting a streaming flush operation 
	-- called by default every 60 seconds per engine (default 2 engines)
	-- use engine:instanceid() to get the engine id 
	-- 
	onmetronome  = function(engine, timestamp, tick_count, tick_interval  )


	  -- lazy open of socket
	  if T.socket ==nil then 
		local api_socket_filename = T.env.get_config("App>RunStateDirectory").."/"..API_SOCKETFILE_NAME .."."..engine:instanceid() 
		if  not TrisulPlugin.open_api_socket( api_socket_filename) then
			return false
		end 
	  end 


      -- this block is repeated  until 
      -- 1. EOF on socket 
	  local done=false
      while not done    do 

        local ret = ffi.C.recv(T.socket, T.rbuf,T.MAX_MSG_SIZE,K.MSG_DONTWAIT)
        if ret < 0 then
          if ffi.errno()  == K.EAGAIN then 
		  	done=true -- eof 
          else 
		  	T.logerror("Error ffi.recv " .. strerror())
		  	print("Error ffi.recv " .. strerror())
			done=true
          end 
        elseif ret >= T.MAX_MSG_SIZE then
          T.log("Ignoring large string, probably not an alert len="..ret);
		  done=true
		else 
			local cmd_string  = ffi.string(T.rbuf, ret)
			TrisulPlugin.dispatch_cmd( engine, timestamp, cmd_string)
        end
      end 

    end

  },

  -- cmd string - split by new line 
  dispatch_cmd = function(engine, timestamp, cmd_string)

  	local args = {}
	for token in cmd_string:gmatch("[^\n]+") do
	   args[#args+1]=token
    end

	print(cmd_string)

	if args[1] =="update_counter" then 
		engine:update_counter( args[2], args[3], tonumber(args[4]), tonumber(args[5]))
	elseif args[1] == "add_alert" then 
		local flowkey=args[3]
		if flowkey == "nil"  then flowkey=nil end
		engine:add_alert( args[2], flowkey, args[4], tonumber(args[5]), args[6])
	elseif args[1] == "add_alert_tca" then 
		engine:add_alert_tca( args[2], tonumber(args[3]), args[4], args[5])
	elseif args[1] == "add_alert_full" then 
		local flowkey=args[3]
		if flowkey == "nil"  then flowkey=nil end
		engine:add_alert_full( args[2], flowkey, args[4], args[5], tonumber(args[6]), args[7],args[8])
	elseif args[1] == "update_key_info" then
		engine:update_key_info( args[2], args[3], args[4])
	else
		print("Unsupported comment, yet! check back")
	end

  end,

}
