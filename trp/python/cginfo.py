'''
# CG Info
# Prints all counter groups 
'''

import sys
import datetime
import trp_pb2
import zmq

def usage():
 print "python ", sys.argv[0],"<zmq_endpoint>"
 print "python ", sys.argv[0],"ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0"


if len(sys.argv) != 2:
  usage()
  sys.exit(2)

 
# helper
def get_response(zmq_endpoint,req):
  #zmq send
  context = zmq.Context()
  socket = context.socket(zmq.REQ)
  socket.connect(zmq_endpoint)
  socket.send(req.SerializeToString())

  #zmq receive
  data=socket.recv()
  resp = unwrap_response(data)
  return resp
  socket.close

# helper
def unwrap_response(data):
  resp = trp_pb2.Message()
  resp.ParseFromString(data)
  for x in  resp.DESCRIPTOR.enum_types:
    name = x.values_by_number.get(int(resp.trp_command)).name
  return {
    'COUNTER_GROUP_INFO_RESPONSE':resp.counter_group_info_response
   }.get(name,resp)

#################
# actual code starts here 
# to retrieve all counter groups send an empty COUNTER_GROUP_INFO_REQUEST

req = trp_pb2.Message()
req.trp_command=req.COUNTER_GROUP_INFO_REQUEST
resp = get_response(sys.argv[1],req)

# display the information 
for cg in resp.group_details:
  print cg.guid  + "," + cg.name 


