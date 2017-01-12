'''
# file_name = counter_group_topper_request.py
# Getting latest 1 hour topper for internal host.
# protoc trp.proto --python_out=. 
# pip install protobuf
# pip install pyzmq
#
'''
import sys
import datetime
import trp_pb2
import zmq

def usage():
 print "python ", sys.argv[0],"<zmq_endpoint> <counter_group> <meter>"
 print "python ", sys.argv[0],"ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0 {889900CC-0063-11A5-8380-FEBDBABBDBEA} 0"
 sys.exit(2)
if len(sys.argv) != 4:
  print "Argument length should be 4"
  usage()

 
#get the availble time from trp 
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

def unwrap_response(data):
  resp = trp_pb2.Message()
  resp.ParseFromString(data)
  for x in  resp.DESCRIPTOR.enum_types:
    name = x.values_by_number.get(int(resp.trp_command)).name
  return {
    'TIMESLICES_RESPONSE': resp.time_slices_response,
    'COUNTER_GROUP_TOPPER_RESPONSE':resp.counter_group_topper_response
   }.get(name,resp)


req = trp_pb2.Message()
req.trp_command=req.TIMESLICES_REQUEST
req.time_slices_request.get_total_window=True
resp = get_response(sys.argv[1],req)


#construct counter group topper request for internal host
req = trp_pb2.Message()
req.trp_command=req.COUNTER_GROUP_TOPPER_REQUEST
req.counter_group_topper_request.counter_group=sys.argv[2]
req.counter_group_topper_request.meter=int(sys.argv[3])

#construct time interval for last 1 hour
tm= trp_pb2.TimeInterval()
tm.to.tv_sec=resp.total_window.to.tv_sec
object=getattr(tm,'from')
object.tv_sec=tm.to.tv_sec-3600

#assign time interval to counter group topper request
req.counter_group_topper_request.time_interval.MergeFrom(tm)
resp = get_response(sys.argv[1],req)
#parse and display 
for key in resp.keys:
  #value = "{0:.2f}".format((key.metric*301)/1024.0**2)
  #Db values stored in bytes
  #300 in bucket size for toppers
  value = round((key.metric*300)/1024.0**2,2)
  print key.label,value


