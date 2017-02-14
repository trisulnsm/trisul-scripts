-- suricata_eve_unixsocket.lua
--
-- same as eve.json file but uses Unix Sockets (via Luajit FFI) 
--
-- Several advantages to using Unix Sockets 
--  1. no need to maintain a waldo file
--  2. no need to poll for file changes 
--
-- We purposely keep the LuaJIT FFI CDEFs in the same file to 
-- reduce the dependencies. You can refactor if you wish. 
--
-- Note     : Just change the EVE_SOCKETFILE to your unsock path 
-- See also : suricata_eve.lua to read from eve.json file 
-- 
--

local ffi=require'ffi'
local JSON=require'JSON'
local EVE_SOCKETFILE='/var/log/nsm/eve.socket'

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
    name = "EVE  Alerts via UNIX DGRAM socket ",
    description = "Suricata to Trisul via Unix DGRAM input filter ",
  },


  -- returning false from onload will effectively stop the script itself
  -- 
  onload = function()

    T.log("Suricata EVE Unix Socket script - setting up the socket : ".. EVE_SOCKETFILE)

    -- socket 
    local socket = ffi.C.socket( K.AF_UNIX, K.SOCK_DGRAM, 0 );
    if  socket == -1 then 
      T.log(T.K.loglevel.ERROR,"Error socket() " .. strerror())
      return 
    end 

    -- bind to unix socket endpoint
    local addr = ffi.new("struct sockaddr_un");
    addr.sun_family = K.AF_UNIX;
    addr.sun_path = EVE_SOCKETFILE
    ffi.C.unlink(addr.sun_path);
    local ret = ffi.C.bind( socket,  ffi.cast("const struct sockaddr *", addr) , ffi.sizeof(addr));


    print ("Ret = "..ret.." pah="..ffi.string(addr.sun_path) )
    if ret == -1 then
        T.log(T.K.loglevel.ERROR, "Error bind() " .. strerror())
        return false
    end

    T.socket = socket

   end,


  inputfilter  = {

    -- 
    -- this function must either return nil or a table {..} with alert details
    -- Rule 1:  no blocking 
    -- Rule 2:  handle the JSON yourself here in LUA
    -- 
    step_alert  = function()

      local MAX_MSG_SIZE=2048;
      local rbuf  = ffi.new("char[?]", MAX_MSG_SIZE);

      -- this block is repeated 
      -- 1. until an 'alert' JSON is found (suricata sends other types of info too via EVE))
      -- 2. EOF on socket 
      local p = nil 
      repeat 
        local ret = ffi.C.recv(T.socket, rbuf,MAX_MSG_SIZE,K.MSG_DONTWAIT)
        if ret < 0 then
          if ffi.errno()  == K.EAGAIN then 
            print("Nothing to read" )
            return nil
          else 
            print("Error ffi.recv " .. strerror())
            return nil 
          end 
        end

        if ret >= MAX_MSG_SIZE then
          T.log("Ignoring large JSON, probably not an alert len="..ret);
          return nil
        end

        local alert_string = ffi.string(rbuf)
        p = JSON:decode(alert_string)

        until p["event_type"] ==   "alert" 


        -- basically a mapping of EVE to Trisul Alert
        -- notice the AlertGUID 9AF.. this is what Trisul uses to show IDS alerts from Snort
        -- if you want you can create your own AlertGroup using the alert group LUA 
      local tv_sec, tv_usec = epoch_secs( p["timestamp"]);
      local ret =  {

        AlertGroupGUID='{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}',     -- Trisul alert group = External IDS 
        TimestampSecs = tv_sec,                                      -- Epoch based time stamps
        TimestampUsecs = tv_usec,
        SigIDKey = p.alert["signature_id"],                          -- SigIDKey is mandatory 
        SigIDLabel = p.alert["signature"],                           -- User Label for the above SigIDKey 
        SourceIP = p["src_ip"],                                      -- IP and Port pretty direct mappings
        SourcePort = p["src_port"],
        DestIP = p["dest_ip"],
        DestPort = p["dest_port"],
        Protocol = protocol_num(p["proto"]),                         -- convert TCP to 6 
        SigRev = p.alert["rev"],
        Priority = p.alert["severity"],
        ClassificationKey = p.alert["category"],
        AlertStatus=p.alert["action"],                                -- allowed/blocked like ALARM/CLEAR
        AlertDetails=p.alert["signature"]                             -- why waste a text field 'AlertDetails'?
      };


      return ret;
    end

  },

}

-- trisul wants tv_sec, tv_usec so.here 
epoch_secs = function( suri_rfc3339)
    local year , month , day , hour , min , sec , tv_usec, patt_end = 
                suri_rfc3339:match ( "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt](%d%d%.?%d*):(%d%d):(%d%d).(%d+)+()" );

    local tv_sec  = os.time( { year = year, month = month, day = day, hour = hour, min = min, sec = sec});

    return tv_sec,tv_usec 

end

-- trisul wants numeric IP protocol number so we do this ! 
protocol_num = function(protoname)

    if protoname == "TCP" then return 6 
    elseif protoname == "UDP" then return 17
    elseif protoname == "ICMP" then return 1
    else return 0; end 

end

