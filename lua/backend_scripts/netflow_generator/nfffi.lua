-- nfffi : LuaJIT FFI  definitions 
--         we use these to send out Netflow packets 

local _ffi=require'ffi'

-- this cdef is the tough part 
_ffi.cdef[[

typedef int      ssize_t;
typedef uint16_t sa_family_t;
typedef uint32_t socklen_t;
typedef uint32_t in_addr_t;

void *memset(void *s, int c, size_t n);

struct constants {
  static const int AF_INET=2;
  static const int SOCK_DGRAM=2;     /* socket.h        */
};


struct sockaddr_in {
    sa_family_t   sin_family;      
	uint16_t	  sin_port;
    uint32_t  	  sin_addr;  
	char		  pad[8];
};

int socket(int domain, int type, int protocol);
int close(int fd);
in_addr_t inet_addr(const char *cp);
uint32_t htonl(uint32_t hostlong);
uint16_t htons(uint16_t hostshort);
ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
	           const struct sockaddr *dest_addr, socklen_t addrlen);
char  * strerror(int errno);

/* Netflow v5 header */
typedef  struct nf5_header {
	uint16_t	version;
	uint16_t	count;
	uint32_t	sysuptime;
	uint32_t	tv_sec;
	uint32_t	tv_nsec;
	uint32_t	flow_id;
	uint8_t	    engine_type;
	uint8_t	    engine_id;
	uint16_t	sampling;
} nf5_header;


/* Netflow v5 record */
typedef struct nf5_record {
	uint32_t 	source_ip;
	uint32_t	dest_ip;
	uint32_t    next_hop_ip;
	uint16_t	ifindex_in;
	uint16_t    ifindex_out;
	uint32_t	packet_count;
	uint32_t	byte_count;
	uint32_t	sysuptime_from;
	uint32_t	sysuptime_to;
	uint16_t	source_port;
	uint16_t	dest_port;
	uint8_t	    pad_1;
	uint8_t	    tcp_flags;
	uint8_t	    l4_protocol;
	uint8_t	    ip_tos;
	uint16_t	source_as;
	uint16_t	dest_as;
	uint8_t	    source_mask_bits;
	uint8_t	    dest_mask_bits;
	uint16_t    pad_2;

} nf5_record;


typedef struct nf5_packet {
	nf5_header	header;
	nf5_record  records[25]; 
} nf5_packet;

]] 

return _ffi

