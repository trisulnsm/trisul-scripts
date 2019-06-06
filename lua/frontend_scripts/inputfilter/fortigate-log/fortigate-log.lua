--
--  fortigate-log.lua
--
--  Type : InputFilter
--
--  listens to Fortigate logs and pumps the trisul-probe pipeline 
--
--  reference : Fortigate 6.2 Sample Logs by logtype 
--  https://docs.fortinet.com/document/fortigate/6.2.0/cookbook/986892/sample-logs-by-log-type
-- 
--  UDP Port is 

local ffi=require'ffi'
local FI=require'flowimport'

-- FFI 
ffi.cdef[[

  typedef int      ssize_t;
  typedef uint16_t sa_family_t;
  typedef uint32_t socklen_t;

  struct constants {
    static const int AF_UNIX=1;
    static const int AF_INET=2;
    static const int SOCK_DGRAM=2;          
    static const int MSG_DONTWAIT=0x40;    
    static const uint32_t INADDR_ANY=0x0;    
  };


  struct sockaddr {
    sa_family_t sa_family;          
    char        sa_data[14];       
  };

  struct in_addr {
    uint32_t s_addr;
  };

  struct sockaddr_in {
    uint16_t   sin_family;
    uint16_t   sin_port;
    struct     in_addr sin_addr;
    char       sin_zero[8];
  };
                              
  int       socket(int domain, int type, int protocol);
  int       bind(int socket, const struct sockaddr *, socklen_t addrlen) ;
  ssize_t   recvfrom(int socket, void * buf, size_t buflen, int flags, struct sockaddr *src_addr, socklen_t *addrlen);
  size_t    strlen(const char * s);
  char *    strerror(int errno);
  int       close(int fd);
  uint16_t  htons(uint16_t hostshort);
  char *    inet_ntoa(struct in_addr in);
]] 


strerror = function()
  return ffi.string(ffi.C.strerror( ffi.errno() ))
end

K = ffi.new("struct constants");

UDPLOGPORT=5111
ACTIVETIMEOUT=180

TrisulPlugin = {

  id = {
    name = "Fortigate log processor", 
    description = "Fortigate",
  },

  -- open the UDP port for receiving logs , use ffi 
  onload = function()

    T.loginfo("Opening UDP port for logs ".. UDPLOGPORT)

    -- socket 
    local socket = ffi.C.socket( K.AF_INET, K.SOCK_DGRAM, 0 );
    if  socket == -1 then 
      T.log(T.K.loglevel.ERROR,"Error socket() " .. strerror())
      return 
    end 

    -- bind to socket endpoint
    local server_address = ffi.new("struct sockaddr_in[1]", {{
            sin_family = K.AF_INET,
            sin_addr = {
              s_addr = K.INADDR_ANY,
            },
            sin_port = ffi.C.htons(UDPLOGPORT),
         }})


    local ret = ffi.C.bind( socket,  ffi.cast("const struct sockaddr *", server_address) , ffi.sizeof(server_address[0]));
    if ret == -1 then
        T.log(T.K.loglevel.ERROR, "Error bind() " .. strerror())
        return false
    end

    T.socket = socket

    print("Successfully opened UDP log port : "..UDPLOGPORT)
  end,



  -- close 
  onunload = function ()
    ffi.C.close(T.socket)
    T.log("Bye closing");
  end,


  -- we're doing input filter 
  inputfilter  = {

    -- 
    -- read the next log msg  and update flow metrics 
    step  = function(packet, engine)

      local MAX_MSG_SIZE=2048;
      local rbuf  = ffi.new("char[?]", MAX_MSG_SIZE);
      local client_addr= ffi.new("struct sockaddr_in[1]")
      local client_addrlen = ffi.new("socklen_t[1]")
      client_addrlen[0]=ffi.sizeof(client_addr[0])
      local ret = ffi.C.recvfrom(T.socket,rbuf,MAX_MSG_SIZE,0, ffi.cast("struct sockaddr*", client_addr), ffi.cast("socklen_t*",client_addrlen))
      if ret < 0 then
        print("Error ffi.recv " .. strerror())
        return nil 
      end 

      --convert whole into a table
      local paystr = ffi.string(rbuf)
      local logtbl = {}
      for a,b in paystr:gmatch('(%S+)=(%S+)') do 
        logtbl[a]=b:gsub('"','')
      end 


      if logtbl['type'] ~= 'traffic' then
        return true
      end 

      if logtbl['action'] == 'deny' then
        return true
      end 

      if string.find(logtbl['srcip'],":",1,true) then 
        return true
      end

      logtbl['duration']= logtbl['duration'] or 1 
      -- adjust values
      if tonumber(logtbl['duration']) > 2 * ACTIVETIMEOUT then
        logtbl['sentbyte']= logtbl['sentdelta']
        logtbl['rcvdbyte']= logtbl['rcvddelta']
        logtbl['duration']= ACTIVETIMEOUT
      end

      -- hash the int
      logtbl['srcintfhash']=T.util.hash( logtbl['srcintf'], 16)
      logtbl['dstintfhash']=T.util.hash( logtbl['dstintf'], 16)

      -- router ip 
      logtbl['routerip'] = ffi.string( ffi.C.inet_ntoa( client_addr[0].sin_addr))

      -- adjust
      packet:set_timestamp(tonumber(logtbl['eventtime']))

      if logtbl.sentbyte then 
        FI.process_flow( engine,  {
           first_timestamp=        tonumber(logtbl['eventtime']),   -- unix epoch secs when flow first seen
           last_timestamp=         tonumber(logtbl['eventtime']) + tonumber(logtbl['duration']),   -- unix epoch secs  when last seen 
           router_ip=              logtbl['routerip'],   -- router (exporter ip) dotted ip format
           protocol=               logtbl['proto'],   -- ip protocol number 0-255
           source_ip=              logtbl['srcip'],   -- dotted ip format
           source_port=            logtbl['srcport'],   -- source port number 0-65535
           destination_ip=         logtbl['dstip'],   -- dotted ip 
           destination_port=       logtbl['dstport'],   -- source port number 0-65535
           input_interface=        logtbl['srcintfhash'],   -- ifIndex IN of flow 0-65535
           output_interface=       logtbl['dstintfhash'],   -- ifIndex OUT of flow 0-65535
           bytes=                  logtbl['sentbyte'],   -- octets, 
           packets=                logtbl['sentpkt'] or 1,   -- octets, 
           -- optional --                      
           source_label=           logtbl['srcname'],
           input_interface_label=  logtbl['srcintf'],
           output_interface_label= logtbl['dstintf'],
           router_label=           logtbl['devname']
        })
      end 

      if logtbl.rcvdbyte then 
        FI.process_flow( engine,  {
           first_timestamp=        tonumber(logtbl['eventtime']),   -- unix epoch secs when flow first seen
           last_timestamp=         tonumber(logtbl['eventtime']) + tonumber(logtbl['duration']),   -- unix epoch secs  when last seen 
           router_ip=              logtbl['routerip'],   -- router (exporter ip) dotted ip format
           protocol=               logtbl['proto'],   -- ip protocol number 0-255
           source_ip=              logtbl['dstip'],   -- dotted ip format
           source_port=            logtbl['dstport'],   -- source port number 0-65535
           destination_ip=         logtbl['srcip'],   -- dotted ip 
           destination_port=       logtbl['srcport'],   -- source port number 0-65535
           input_interface=        logtbl['dstintfhash'],   -- ifIndex IN of flow 0-65535
           output_interface=       logtbl['srcintfhash'],   -- ifIndex OUT of flow 0-65535
           bytes=                  logtbl['rcvdbyte'],   -- octets, 
           packets=                logtbl['rcvdpkt'] or 1,   -- octets, 
        })
      end 

    return true 

  end 
          
 },

}

