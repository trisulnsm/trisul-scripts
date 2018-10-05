require 'net/http'
require 'net/https'


# set up unix socket
apis = Socket.new(:UNIX, :DGRAM)  # UNIX datagram socket
s1_ai = Socket.sockaddr_un("/usr/local/var/lib/trisul-probe/domain0/probe0/context0/run/api.sock.0")
apis.connect(s1_ai)

#uri = URI.parse("https://192.168.2.99")
uri = URI.parse("https://api.saas.paytm.com")
request = Net::HTTP.new(uri.host, uri.port)

while true do 
  t1=(Time.now.to_f*1000000).to_i
  response = request.get("/")
  t2=(Time.now.to_f*1000000).to_i

  us_latency  = t2-t1

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n0\n1",0)

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n1\n#{us_latency}",0)

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n2\n#{us_latency}",0)

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n3\n#{us_latency}",0)

  puts(us_latency)

end


