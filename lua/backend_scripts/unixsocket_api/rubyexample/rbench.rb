require 'net/http'
require 'net/https'


# set up unix socket
apis = UNIXSocket.new("/usr/local/var/lib/trisul-probe/domain0/probe0/context0/run/api.sock.0")

uri = URI.parse("https://192.168.2.99")
request = Net::HTTP.new(uri.host, uri.port)

while true do 
  t1=(Time.now.to_f*1000000).to_i
  response = request.get("/")
  t2=(Time.now.to_f*1000000).to_i

  us_latency  = t2-t1

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n0\n1")

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n1\n#{us_latency}")

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n2\n#{us_latency}")

  apis.send("update_counter\n{9497A90C-86DF-44A5-439F-3B4092792728}\ntest_192.168.2.99=\n3\n#{us_latency}")

end


