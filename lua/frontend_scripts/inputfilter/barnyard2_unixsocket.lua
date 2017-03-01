-- barnyard2_alert.lua
--
-- Reads unified2_  structs from barnyard2_ unix_socket
--
-- The UNIX_SOCKETFILE is the path to the unix socket that barnyard2 is goign to 
-- write to  based on the following parameters in barnyard2.conf
--
--     config logdir: /nsm/sensor_data/devbox-System-Product-Name-eth2
--     output alert_unixsock
--
-- Note that you can have multiple copies of this script, under different filenames of
-- course listening to different UNIX_SOCKETFILE to inteface N instances of by2.
--
--
local ffi=require'ffi'
local UNIX_SOCKETFILE='/nsm/sensor_data/devbox-System-Product-Name-eth2/barnyard2_alert'

-- local dbg=require'debugger'

-- 
-- luaJIT the C stuffs 
--
ffi.cdef[[

typedef int   ssize_t;
typedef uint16_t sa_family_t;
typedef uint32_t socklen_t;

struct constants {
    static const int AF_UNIX=1;
    static const int AF_INET=2;
    static const int SOCK_DGRAM=2;          /* socket.h        */
    static const int MSG_DONTWAIT=0x40;     /* socket_type.h   */
    static const int EAGAIN=11;             /* asm../errno.h */
};

int     socket(int domain, int type, int protocol);
uint16_t ntohs(uint16_t netshort);
uint32_t ntohl(uint32_t netlong);
const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);

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


typedef struct _Unified2EventCommon
{
    uint32_t sensor_id;
    uint32_t event_id;
    uint32_t event_second;
    uint32_t event_microsecond;
    uint32_t signature_id;
    uint32_t generator_id;
    uint32_t signature_revision;
    uint32_t classification_id;
    uint32_t priority_id;
} Unified2EventCommon;


typedef struct _AlertpktUnified2
{
    uint8_t  alertmsg[256];                 /* variable.. */
    uint8_t  pcap_pkt_header_ignored[24];   /* 64-bit tv_sec version of pcap_pkthdr */
    uint32_t dlthdr;                        /* datalink header offset. (ethernet, etc.. ) */
    uint32_t nethdr;                        /* network header offset. (ip etc...) */
    uint32_t transhdr;                      /* transport header offset (tcp/udp/icmp ..) */
    uint32_t data;
    uint32_t val;                           /* which fields are valid. (NULL could be
                                             * valids also) */
    uint8_t pkt[1514];              /* from barnyard2 decode.h */
    Unified2EventCommon  event;
} AlertpktUnified2;

]] 


strerror = function()
  return ffi.string(ffi.C.strerror( ffi.errno() ))
end

K = ffi.new("struct constants");

TrisulPlugin = {

  id = {
    name = "Barnyard2 unsock alerts",
    description = "Unified2 from unix_socket from barynard2 ",
  },


  -- returning false from onload will effectively stop the script itself
  -- 
  onload = function()

    -- socket 
    local socket = ffi.C.socket( K.AF_UNIX, K.SOCK_DGRAM, 0 );
    if  socket == -1 then 
        T.log(T.K.loglevel.ERROR,"Error socket() " .. strerror())
        return  false 
    end 

    -- bind to unix socket endpoint
    local addr = ffi.new("struct sockaddr_un");
    addr.sun_family = K.AF_UNIX;
    addr.sun_path = UNIX_SOCKETFILE;
    ffi.C.unlink(addr.sun_path);
    local ret = ffi.C.bind( socket,  ffi.cast("const struct sockaddr *", addr) , ffi.sizeof(addr));
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

      local rbuf  = ffi.new("char[?]", ffi.sizeof("AlertpktUnified2"));

      local ret = ffi.C.recv(T.socket, rbuf,ffi.sizeof("AlertpktUnified2"),K.MSG_DONTWAIT)
      if ret < 0 then
        if ffi.errno()  == K.EAGAIN then 
          print("Nothing to read" )
          return nil
        else 
          print("Error ffi.recv " .. strerror())
          return nil 
        end 
      end

      print ("Read bytes=".. ret);

      local alert_pkt  = ffi.cast( "AlertpktUnified2*", rbuf);
      local buf = ffi.new("char[?]",32);

      local source_ip = ffi.string(ffi.C.inet_ntop( K.AF_INET,  alert_pkt.pkt + alert_pkt.nethdr + 12,  buf, 32)); 
      local dest_ip   = ffi.string(ffi.C.inet_ntop( K.AF_INET,  alert_pkt.pkt + alert_pkt.nethdr + 16,  buf, 32)); 
      local source_port = ffi.C.ntohs( ffi.cast("uint16_t*", alert_pkt.pkt + alert_pkt.transhdr + 0)[0]);
      local dest_port = ffi.C.ntohs( ffi.cast("uint16_t*", alert_pkt.pkt + alert_pkt.transhdr + 2)[0]);
      local ip_protocol = ffi.cast("uint8_t*", alert_pkt.pkt + alert_pkt.nethdr + 9)[0];

      local new_alert =  {

        AlertGroupGUID='{9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}',     -- Trisul alert group = External IDS 
        TimestampSecs = ffi.C.ntohl(alert_pkt.event.event_second),   -- Epoch based time stamps
        TimestampUsecs = ffi.C.ntohl(alert_pkt.event.event_microsecond),
        SigIDKey = ffi.C.ntohl(alert_pkt.event.signature_id),        -- SigIDKey is mandatory 
        SigIDLabel = ffi.string(alert_pkt.alertmsg),                 -- User Label for the above SigIDKey 
        SourceIP = source_ip,                                        -- IP and Port pretty direct mappings
        SourcePort = source_port,
        DestIP = dest_ip,
        DestPort = dest_port,
        Protocol = ip_protocol,                                      -- TCP to 6 , UDP to 11 etc
        SigRev = ffi.C.ntohl(alert_pkt.event.signature_revision),
        Priority = ffi.C.ntohl(alert_pkt.event.priority_id),
        ClassificationKey = ffi.C.ntohl(alert_pkt.event.classification_id),
        AlertStatus="FIRED",                                          -- allowed/blocked like ALARM/CLEAR
        AlertDetails="from gen:"..ffi.C.ntohl(alert_pkt.event.generator_id)        -- why waste a text field 'AlertDetails'?
      };

        --      dbg();

      return new_alert;
    end

  },

}
