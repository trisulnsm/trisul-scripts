'''
# file_name = counter_item_request.py
# Getting latest 1 hour traffic for  app https.
# protoc trp.proto --python_out=. 
# pip install protobuf
# pip install pyzmq
#
'''
import sys
import datetime
import trp_pb2
import zmq
import itertools

def usage():
 print "python ", sys.argv[0],"<zmq_endpoint> <counter_group> <key>"
 print "python ", sys.argv[0],"ipc:///usr/local/var/lib/trisul-hub/domain0/hub0/context0/run/trp_0 {C51B48D4-7876-479E-B0D9-BD9EFF03CE2E} p-01BB"
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
    'COUNTER_ITEM_RESPONSE':resp.counter_item_response
   }.get(name,resp)

#Construct time request
req = trp_pb2.Message()
req.trp_command=req.TIMESLICES_REQUEST
req.time_slices_request.get_total_window=True
resp = get_response(sys.argv[1],req)


#construct counter item request request for internal host
req = trp_pb2.Message()
req.trp_command=req.COUNTER_ITEM_REQUEST
req.counter_item_request.counter_group=sys.argv[2]
req.counter_item_request.key.label=sys.argv[3]

#construct time interval for last 1 hour
tm= trp_pb2.TimeInterval()
tm.MergeFrom(resp.total_window)
object=getattr(tm,'from')
object.tv_sec=tm.to.tv_sec-3600

#assign time interval to counter group topper request
req.counter_item_request.time_interval.MergeFrom(tm)
resp = get_response(sys.argv[1],req)
#parse and display 
for stats in resp.stats:
    date = str(datetime.datetime.fromtimestamp(stats.ts_tv_sec))
    #for priting purpose
    values = [[date],stats.values]
    merged = list(itertools.chain.from_iterable(values))
    print("\t".join(str(v) for v in merged))

    

