# Protocol Documentation
<a name="top"/>

## Table of Contents
* [trp.proto](#trp.proto)
 * [AlertT](#TRP.AlertT)
 * [AsyncRequest](#TRP.AsyncRequest)
 * [AsyncResponse](#TRP.AsyncResponse)
 * [ContextConfigRequest](#TRP.ContextConfigRequest)
 * [ContextConfigResponse](#TRP.ContextConfigResponse)
 * [ContextConfigResponse.Layer](#TRP.ContextConfigResponse.Layer)
 * [ContextCreateRequest](#TRP.ContextCreateRequest)
 * [ContextDeleteRequest](#TRP.ContextDeleteRequest)
 * [ContextInfoRequest](#TRP.ContextInfoRequest)
 * [ContextInfoResponse](#TRP.ContextInfoResponse)
 * [ContextInfoResponse.Item](#TRP.ContextInfoResponse.Item)
 * [ContextStartRequest](#TRP.ContextStartRequest)
 * [ContextStopRequest](#TRP.ContextStopRequest)
 * [CounterGroupInfoRequest](#TRP.CounterGroupInfoRequest)
 * [CounterGroupInfoResponse](#TRP.CounterGroupInfoResponse)
 * [CounterGroupT](#TRP.CounterGroupT)
 * [CounterGroupTopperRequest](#TRP.CounterGroupTopperRequest)
 * [CounterGroupTopperResponse](#TRP.CounterGroupTopperResponse)
 * [CounterItemRequest](#TRP.CounterItemRequest)
 * [CounterItemResponse](#TRP.CounterItemResponse)
 * [DeleteAlertsRequest](#TRP.DeleteAlertsRequest)
 * [DocumentT](#TRP.DocumentT)
 * [DocumentT.Flow](#TRP.DocumentT.Flow)
 * [DomainRequest](#TRP.DomainRequest)
 * [DomainResponse](#TRP.DomainResponse)
 * [DomainResponse.Node](#TRP.DomainResponse.Node)
 * [ErrorResponse](#TRP.ErrorResponse)
 * [FileRequest](#TRP.FileRequest)
 * [FileResponse](#TRP.FileResponse)
 * [GrepRequest](#TRP.GrepRequest)
 * [GrepResponse](#TRP.GrepResponse)
 * [HelloRequest](#TRP.HelloRequest)
 * [HelloResponse](#TRP.HelloResponse)
 * [KeySpaceRequest](#TRP.KeySpaceRequest)
 * [KeySpaceRequest.KeySpace](#TRP.KeySpaceRequest.KeySpace)
 * [KeySpaceResponse](#TRP.KeySpaceResponse)
 * [KeyStats](#TRP.KeyStats)
 * [KeyT](#TRP.KeyT)
 * [LogRequest](#TRP.LogRequest)
 * [LogResponse](#TRP.LogResponse)
 * [Message](#TRP.Message)
 * [MeterInfo](#TRP.MeterInfo)
 * [MeterValues](#TRP.MeterValues)
 * [MetricsSummaryRequest](#TRP.MetricsSummaryRequest)
 * [MetricsSummaryResponse](#TRP.MetricsSummaryResponse)
 * [NameValue](#TRP.NameValue)
 * [NodeConfigRequest](#TRP.NodeConfigRequest)
 * [NodeConfigRequest.IntelFeed](#TRP.NodeConfigRequest.IntelFeed)
 * [NodeConfigResponse](#TRP.NodeConfigResponse)
 * [NodeConfigResponse.Node](#TRP.NodeConfigResponse.Node)
 * [OKResponse](#TRP.OKResponse)
 * [PcapRequest](#TRP.PcapRequest)
 * [PcapResponse](#TRP.PcapResponse)
 * [PcapSlicesRequest](#TRP.PcapSlicesRequest)
 * [ProbeStatsRequest](#TRP.ProbeStatsRequest)
 * [ProbeStatsResponse](#TRP.ProbeStatsResponse)
 * [QueryAlertsRequest](#TRP.QueryAlertsRequest)
 * [QueryAlertsResponse](#TRP.QueryAlertsResponse)
 * [QueryFTSRequest](#TRP.QueryFTSRequest)
 * [QueryFTSResponse](#TRP.QueryFTSResponse)
 * [QueryResourcesRequest](#TRP.QueryResourcesRequest)
 * [QueryResourcesResponse](#TRP.QueryResourcesResponse)
 * [QuerySessionsRequest](#TRP.QuerySessionsRequest)
 * [QuerySessionsResponse](#TRP.QuerySessionsResponse)
 * [ResourceT](#TRP.ResourceT)
 * [SearchKeysRequest](#TRP.SearchKeysRequest)
 * [SearchKeysResponse](#TRP.SearchKeysResponse)
 * [SessionT](#TRP.SessionT)
 * [SessionTrackerRequest](#TRP.SessionTrackerRequest)
 * [SessionTrackerResponse](#TRP.SessionTrackerResponse)
 * [StatsArray](#TRP.StatsArray)
 * [StatsTuple](#TRP.StatsTuple)
 * [SubscribeCtl](#TRP.SubscribeCtl)
 * [TimeInterval](#TRP.TimeInterval)
 * [TimeSlicesRequest](#TRP.TimeSlicesRequest)
 * [TimeSlicesResponse](#TRP.TimeSlicesResponse)
 * [TimeSlicesResponse.SliceT](#TRP.TimeSlicesResponse.SliceT)
 * [Timestamp](#TRP.Timestamp)
 * [TopperTrendRequest](#TRP.TopperTrendRequest)
 * [TopperTrendResponse](#TRP.TopperTrendResponse)
 * [UpdateKeyRequest](#TRP.UpdateKeyRequest)
 * [AuthLevel](#TRP.AuthLevel)
 * [CompressionType](#TRP.CompressionType)
 * [DomainNodeType](#TRP.DomainNodeType)
 * [DomainOperation](#TRP.DomainOperation)
 * [Message.Command](#TRP.Message.Command)
 * [MeterInfo.MeterType](#TRP.MeterInfo.MeterType)
 * [PcapFormat](#TRP.PcapFormat)
 * [SubscribeCtl.CtlType](#TRP.SubscribeCtl.CtlType)
 * [SubscribeCtl.StabberType](#TRP.SubscribeCtl.StabberType)
* [Scalar Value Types](#scalar-value-types)

<a name="trp.proto"/>
<p align="right"><a href="#top">Top</a></p>

## trp.proto

trp.proto - Trisul Remote Protocol .proto file
TRP : Trisul Remote Protocol is a remote query API that allows
clients to connect and retrieve data from Trisul Hub

<a name="TRP.AlertT"/>
### AlertT
AlertT : an alert in Trisul 
/  all alert types Threshold Crossing, Flow Tracker, Badfellas, custom alerts use 
/  the same object below

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| sensor_id | [int64](#int64) | optional | source of alert, usually not used |
| time | [Timestamp](#TRP.Timestamp) | required | timestamp |
| alert_id | [string](#string) | required | DB alert ID eg 99:8:98838 |
| source_ip | [KeyT](#TRP.KeyT) | optional | source ip |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| sigid | [KeyT](#TRP.KeyT) | optional | unique key representing alert type |
| classification | [KeyT](#TRP.KeyT) | optional | classification (from IDS terminology) |
| priority | [KeyT](#TRP.KeyT) | optional | priority 1,2,3 |
| dispatch_time | [Timestamp](#TRP.Timestamp) | optional | sent time |
| dispatch_message1 | [string](#string) | optional | a free format string created by generator of alert |
| dispatch_message2 | [string](#string) | optional | second format |
| occurrances | [int64](#int64) | optional | number of occurranes, used by QueryAlerts for aggregation Default: 1 |
| group_by_key | [string](#string) | optional | aggregation key |
| probe_id | [string](#string) | optional | probe generating this alert |
| alert_status | [string](#string) | optional | FIRE,CLEAR,BLOCK etc |
| acknowledge_flag | [int64](#int64) | optional | ACK or NOT |


<a name="TRP.AsyncRequest"/>
### AsyncRequest
AsyncRequest - Asynchrononous query framework 
/      response taken from original , the token

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| token | [int64](#int64) | required |  |
| request_message | [string](#string) | optional |  |


<a name="TRP.AsyncResponse"/>
### AsyncResponse
AsyncResponse   - a token represnting a future response
/  you will get an AsyncResponse  for TRP Request  if you set the run_async=true at the message level

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| token | [int64](#int64) | required | use this token in AsyncRequest polling until you get the original Response you expected |
| response_message | [string](#string) | optional |  |
| response | [Message](#TRP.Message) | optional |  |


<a name="TRP.ContextConfigRequest"/>
### ContextConfigRequest
ContextConfigRequest - start stop status 
/  OK or ERROR response 
/  Status = OK if running with PID etc in message text

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| profile | [string](#string) | optional |  |
| params | [string](#string) | optional |  |
| push_config_blob | [bytes](#bytes) | optional | push this .. |
| query_config | [NameValue](#TRP.NameValue) | repeated | query, leave the .value field blank |
| set_config_values | [NameValue](#TRP.NameValue) | repeated | push this ..  (name=value;name=value ..) |


<a name="TRP.ContextConfigResponse"/>
### ContextConfigResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| profile | [string](#string) | optional |  |
| params | [string](#string) | optional | what kind of config you want |
| pull_config_blob | [bytes](#bytes) | optional | config |
| config_blob | [bytes](#bytes) | optional | compress tar.gz .. |
| endpoints_flush | [string](#string) | repeated |  |
| endpoints_query | [string](#string) | repeated |  |
| endpoints_pub | [string](#string) | repeated |  |
| config_values | [NameValue](#TRP.NameValue) | repeated | query, leave the .value field blank |
| layers | [ContextConfigResponse.Layer](#TRP.ContextConfigResponse.Layer) | repeated |  |


<a name="TRP.ContextConfigResponse.Layer"/>
### ContextConfigResponse.Layer


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| layer | [int64](#int64) | required |  |
| probe_id | [string](#string) | required |  |
| probe_description | [string](#string) | optional |  |


<a name="TRP.ContextCreateRequest"/>
### ContextCreateRequest
ContextRequest  - Context methods 
/  response Ok or Error, follow up with ContextInfo to print details 
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| clone_from | [string](#string) | optional |  |


<a name="TRP.ContextDeleteRequest"/>
### ContextDeleteRequest
ContextDelete  : initialize 
/      reset data only ..

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required | if not  set all context get in |
| reset_data | [bool](#bool) | optional | reset data dont delete everything |


<a name="TRP.ContextInfoRequest"/>
### ContextInfoRequest
ContextInfo : one or all contexts
/  use is_init to prime with config

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | optional | if not  set all context get in |
| get_size_on_disk | [bool](#bool) | optional | get size on disk (expensive) Default: false |


<a name="TRP.ContextInfoResponse"/>
### ContextInfoResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| items | [ContextInfoResponse.Item](#TRP.ContextInfoResponse.Item) | repeated |  |


<a name="TRP.ContextInfoResponse.Item"/>
### ContextInfoResponse.Item


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| is_initialized | [bool](#bool) | required |  |
| is_running | [bool](#bool) | required |  |
| size_on_disk | [int64](#int64) | optional |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| is_clean | [bool](#bool) | optional |  |
| extrainfo | [string](#string) | optional |  |
| run_history | [TimeInterval](#TRP.TimeInterval) | repeated |  |
| profile | [string](#string) | optional |  |
| runmode | [string](#string) | optional |  |
| node_version | [string](#string) | optional |  |


<a name="TRP.ContextStartRequest"/>
### ContextStartRequest
ContextStart  : run 
/      run data only ..

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required | if not  set all context get in |
| mode | [string](#string) | optional |  |
| background | [bool](#bool) | optional |  |
| pcap_path | [string](#string) | optional |  |
| run_tool | [string](#string) | optional | snort, suricata supported.. |
| tool_ids_config | [string](#string) | optional |  |
| tool_av_config | [string](#string) | optional |  |


<a name="TRP.ContextStopRequest"/>
### ContextStopRequest
ContextSttop  : kill  the context processes

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required | if not  set all context get in |
| run_tool | [string](#string) | optional | snort, suricata , trp, flushd supported.. |


<a name="TRP.CounterGroupInfoRequest"/>
### CounterGroupInfoRequest
CounterGroupInfoRequest - retrieve information about enabled counter groups

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | optional |  |
| get_meter_info | [bool](#bool) | optional |  Default: false |


<a name="TRP.CounterGroupInfoResponse"/>
### CounterGroupInfoResponse
CounterGroupInfoResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| group_details | [CounterGroupT](#TRP.CounterGroupT) | repeated |  |


<a name="TRP.CounterGroupT"/>
### CounterGroupT
CounterGroupT : Represents a counter group 
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| guid | [string](#string) | required | guid identifying the CG |
| name | [string](#string) | required | CG name |
| bucket_size | [int64](#int64) | optional | bucketsize for all meters in this group |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional | total time interval available in DB |
| topper_bucket_size | [int64](#int64) | optional | topper bucketsize (streaming analytics window) |
| meters | [MeterInfo](#TRP.MeterInfo) | repeated | array of meter information (m0, m1, .. mn) |


<a name="TRP.CounterGroupTopperRequest"/>
### CounterGroupTopperRequest
CounterGroupTopperRequest  - retrieve toppers for a counter group (top-K)

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required | guid of CG |
| meter | [int64](#int64) | optional | meter; eg to get Top Hosts By Connections use cg=Hosts meter = 6(connections) Default: 0 |
| maxitems | [int64](#int64) | optional | number of top items to retreive Default: 100 |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional | time interval |
| time_instant | [Timestamp](#TRP.Timestamp) | optional |  |
| flags | [int64](#int64) | optional |  |
| resolve_keys | [bool](#bool) | optional | retrieve labels as set in the response for each key Default: true |


<a name="TRP.CounterGroupTopperResponse"/>
### CounterGroupTopperResponse
CounterGroupTopperResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required | request cgid |
| meter | [int64](#int64) | required | from request |
| sysgrouptotal | [int64](#int64) | optional | the metric value for &quot;Others..&quot;  after Top-K |
| keys | [KeyT](#TRP.KeyT) | repeated | topper keys, KeyT.metric contains the top-k value |


<a name="TRP.CounterItemRequest"/>
### CounterItemRequest
CounterItemRequest : Time series history statistics for an item

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required | guid of counter group |
| meter | [int64](#int64) | optional | optional meter, default will retrieve all (same cost) |
| key | [KeyT](#TRP.KeyT) | required | key (can specify key.key, key.label, etc too |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required | Time interval for query |
| volumes_only | [int64](#int64) | optional | if '1' ; then only retrieves totals for each meter Default: 0 |


<a name="TRP.CounterItemResponse"/>
### CounterItemResponse
CounterItemResponse  -

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required | guid of CG |
| key | [KeyT](#TRP.KeyT) | required | key : filled up with readable,label automatically |
| totals | [StatsArray](#TRP.StatsArray) | optional | if volumes_only = 1 in request, this contains totals for each metric |
| stats | [StatsArray](#TRP.StatsArray) | repeated | time series stats - can use to draw charts etc |


<a name="TRP.DeleteAlertsRequest"/>
### DeleteAlertsRequest
DeleteAlerts
/  - very limited exception to Trisul rule of not having delete options

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| alert_group | [string](#string) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| sigid | [KeyT](#TRP.KeyT) | optional |  |
| classification | [KeyT](#TRP.KeyT) | optional |  |
| priority | [KeyT](#TRP.KeyT) | optional |  |
| any_ip | [KeyT](#TRP.KeyT) | optional |  |
| any_port | [KeyT](#TRP.KeyT) | optional |  |
| message_regex | [string](#string) | optional | delete using regex |


<a name="TRP.DocumentT"/>
### DocumentT
DocumentT : a full text document 
/     full HTTP headers, printable TLS certs, etc

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| dockey | [string](#string) | required | unique id |
| fts_attributes | [string](#string) | optional | attibutes used for facets |
| fullcontent | [string](#string) | optional | full document text |
| flows | [DocumentT.Flow](#TRP.DocumentT.Flow) | repeated | list of flows where this doc was seen |
| probe_id | [string](#string) | optional |  |


<a name="TRP.DocumentT.Flow"/>
### DocumentT.Flow
this document was seen at these time and on this flow

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time | [Timestamp](#TRP.Timestamp) | required |  |
| key | [string](#string) | required |  |


<a name="TRP.DomainRequest"/>
### DomainRequest
messages to routerX backend

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| cmd | [DomainOperation](#TRP.DomainOperation) | required |  |
| station_id | [string](#string) | optional |  |
| params | [string](#string) | optional |  |
| nodetype | [DomainNodeType](#TRP.DomainNodeType) | optional |  |


<a name="TRP.DomainResponse"/>
### DomainResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| cmd | [DomainOperation](#TRP.DomainOperation) | required |  |
| nodes | [DomainResponse.Node](#TRP.DomainResponse.Node) | repeated |  |
| req_params | [string](#string) | optional |  |
| params | [string](#string) | optional |  |
| need_reconnect | [bool](#bool) | optional |  Default: false |


<a name="TRP.DomainResponse.Node"/>
### DomainResponse.Node


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [string](#string) | required |  |
| nodetype | [DomainNodeType](#TRP.DomainNodeType) | required |  |
| station_id | [string](#string) | optional |  |
| extra_info | [string](#string) | optional |  |
| register_time | [Timestamp](#TRP.Timestamp) | optional |  |
| heartbeat_time | [Timestamp](#TRP.Timestamp) | optional |  |


<a name="TRP.ErrorResponse"/>
### ErrorResponse
ErrorResponse
/ All XYZRequest() messages can either generate a XYZResponse() or an ErrorResponse()
/ you need to handle the error case

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| original_command | [int64](#int64) | required | Command ID of request |
| error_code | [int64](#int64) | required | numeric error code |
| error_message | [string](#string) | required | error string |


<a name="TRP.FileRequest"/>
### FileRequest
FileRequest   - used to download files from Trisul domain nodes like probes

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| uri | [string](#string) | required | uri of resource you want to download , example PcapResponse.save_file |
| position | [int64](#int64) | required | seek position in that file |
| params | [string](#string) | optional | local meaning sentback n response |
| context_name | [string](#string) | optional | context name |
| delete_on_eof | [bool](#bool) | optional |  Default: false |


<a name="TRP.FileResponse"/>
### FileResponse
FileResponse
/      one chunk at at time, Trisul has slightly inefficient File Transfer
/      for very large files, since most files are data feeds  &lt; 100MB fine for now

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| uri | [string](#string) | required | requested URI |
| eof | [bool](#bool) | required | end of all chunks |
| position | [int64](#int64) | optional | current  position |
| content | [bytes](#bytes) | optional | file chunk content |
| request_params | [string](#string) | optional |  |
| context_name | [string](#string) | optional |  |


<a name="TRP.GrepRequest"/>
### GrepRequest
GrepRequest - reconstruct and search for patterns in saved packets

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| flowcutoff_bytes | [int64](#int64) | optional |  |
| pattern_hex | [string](#string) | optional | hex patttern |
| pattern_text | [string](#string) | optional | plain text |
| pattern_file | [string](#string) | optional | a file - must be available at probe |
| md5list | [string](#string) | repeated | a list of MD5 matching the content |
| resolve_keys | [bool](#bool) | optional |  Default: true |


<a name="TRP.GrepResponse"/>
### GrepResponse
GrepResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| sessions | [SessionT](#TRP.SessionT) | repeated | sessionT with keys containing the content |
| hints | [string](#string) | repeated | some surrounding context for the match |
| probe_id | [string](#string) | optional |  |


<a name="TRP.HelloRequest"/>
### HelloRequest
Hello Request : use to check connectivity

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| station_id | [string](#string) | required | an id of the query client trying to connect |
| message | [string](#string) | optional | a message (will be echoed back in response) |


<a name="TRP.HelloResponse"/>
### HelloResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| station_id | [string](#string) | required | station id of the query server |
| station_id_request | [string](#string) | optional | station id found in the request |
| message | [string](#string) | optional | message found in the request |
| local_timestamp | [int64](#int64) | optional | local timestamp at server, used to detect drifts |


<a name="TRP.KeySpaceRequest"/>
### KeySpaceRequest
KeySpaceRequest - search hits in Key Space 
/ for example you can search the key space 10.0.0.0 to 11.0.0.0 to get all IP 
/ seen in that range

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| spaces | [KeySpaceRequest.KeySpace](#TRP.KeySpaceRequest.KeySpace) | repeated |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |


<a name="TRP.KeySpaceRequest.KeySpace"/>
### KeySpaceRequest.KeySpace


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| from_key | [KeyT](#TRP.KeyT) | required | from key representing start of keyspace |
| to_key | [KeyT](#TRP.KeyT) | required | end of key space |


<a name="TRP.KeySpaceResponse"/>
### KeySpaceResponse
KeySpaceResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | optional |  |
| hits | [KeyT](#TRP.KeyT) | repeated | array of keys in the requested space |


<a name="TRP.KeyStats"/>
### KeyStats
KeyStats - A full time series item (countergroup, key, timeseries) 
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required | guid of counter group |
| key | [KeyT](#TRP.KeyT) | required | key representing an item |
| meters | [MeterValues](#TRP.MeterValues) | repeated | array of timeseries (timeseries-meter0, ts-meter1, ...ts-meter-n) |


<a name="TRP.KeyT"/>
### KeyT
KeyT : Represents a Key 
/ Top level objects are named ObjT 
/   eg KeyT - Key Type, SessionT - Session Type etc.

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| key | [string](#string) | optional | key in trisul key format eg, C0.A8.01.02 for 192.168.1.2 |
| readable | [string](#string) | optional | human friendly name |
| label | [string](#string) | optional | a user label eg, a hostname or manually assigned name |
| description | [string](#string) | optional | description |
| metric | [int64](#int64) | optional | optional : a single metric value - relevant to the query used |


<a name="TRP.LogRequest"/>
### LogRequest
LogRequest  - get log file  from a domain node

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| log_type | [string](#string) | required |  |
| regex_filter | [string](#string) | optional |  |
| maxlines | [int64](#int64) | optional |  Default: 1000 |
| continue_logfilename | [string](#string) | optional |  |
| continue_seekpos | [int64](#int64) | optional |  |
| latest_run_only | [bool](#bool) | optional |  Default: false |


<a name="TRP.LogResponse"/>
### LogResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| logfilename | [string](#string) | optional |  |
| seekpos | [int64](#int64) | optional |  |
| log_lines | [string](#string) | repeated | compressed gz |


<a name="TRP.Message"/>
### Message
Top level message is TRP::Message
/ wraps the actual request or response 
/ 
/ You must set trp.command = &lt;cmd&gt; for EACH request in addition to 
/ constructing the actual TRP request message 
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| trp_command | [Message.Command](#TRP.Message.Command) | required |  |
| hello_request | [HelloRequest](#TRP.HelloRequest) | optional |  |
| hello_response | [HelloResponse](#TRP.HelloResponse) | optional |  |
| ok_response | [OKResponse](#TRP.OKResponse) | optional |  |
| error_response | [ErrorResponse](#TRP.ErrorResponse) | optional |  |
| counter_group_topper_request | [CounterGroupTopperRequest](#TRP.CounterGroupTopperRequest) | optional |  |
| counter_group_topper_response | [CounterGroupTopperResponse](#TRP.CounterGroupTopperResponse) | optional |  |
| counter_item_request | [CounterItemRequest](#TRP.CounterItemRequest) | optional |  |
| counter_item_response | [CounterItemResponse](#TRP.CounterItemResponse) | optional |  |
| pcap_request | [PcapRequest](#TRP.PcapRequest) | optional |  |
| pcap_response | [PcapResponse](#TRP.PcapResponse) | optional |  |
| search_keys_request | [SearchKeysRequest](#TRP.SearchKeysRequest) | optional |  |
| search_keys_response | [SearchKeysResponse](#TRP.SearchKeysResponse) | optional |  |
| counter_group_info_request | [CounterGroupInfoRequest](#TRP.CounterGroupInfoRequest) | optional |  |
| counter_group_info_response | [CounterGroupInfoResponse](#TRP.CounterGroupInfoResponse) | optional |  |
| update_key_request | [UpdateKeyRequest](#TRP.UpdateKeyRequest) | optional |  |
| query_sessions_request | [QuerySessionsRequest](#TRP.QuerySessionsRequest) | optional |  |
| query_sessions_response | [QuerySessionsResponse](#TRP.QuerySessionsResponse) | optional |  |
| session_tracker_request | [SessionTrackerRequest](#TRP.SessionTrackerRequest) | optional |  |
| session_tracker_response | [SessionTrackerResponse](#TRP.SessionTrackerResponse) | optional |  |
| probe_stats_request | [ProbeStatsRequest](#TRP.ProbeStatsRequest) | optional |  |
| probe_stats_response | [ProbeStatsResponse](#TRP.ProbeStatsResponse) | optional |  |
| query_alerts_request | [QueryAlertsRequest](#TRP.QueryAlertsRequest) | optional |  |
| query_alerts_response | [QueryAlertsResponse](#TRP.QueryAlertsResponse) | optional |  |
| query_resources_request | [QueryResourcesRequest](#TRP.QueryResourcesRequest) | optional |  |
| query_resources_response | [QueryResourcesResponse](#TRP.QueryResourcesResponse) | optional |  |
| grep_request | [GrepRequest](#TRP.GrepRequest) | optional |  |
| grep_response | [GrepResponse](#TRP.GrepResponse) | optional |  |
| topper_trend_request | [TopperTrendRequest](#TRP.TopperTrendRequest) | optional |  |
| topper_trend_response | [TopperTrendResponse](#TRP.TopperTrendResponse) | optional |  |
| subscribe_ctl | [SubscribeCtl](#TRP.SubscribeCtl) | optional |  |
| query_fts_request | [QueryFTSRequest](#TRP.QueryFTSRequest) | optional |  |
| query_fts_response | [QueryFTSResponse](#TRP.QueryFTSResponse) | optional |  |
| time_slices_request | [TimeSlicesRequest](#TRP.TimeSlicesRequest) | optional |  |
| time_slices_response | [TimeSlicesResponse](#TRP.TimeSlicesResponse) | optional |  |
| delete_alerts_request | [DeleteAlertsRequest](#TRP.DeleteAlertsRequest) | optional |  |
| metrics_summary_request | [MetricsSummaryRequest](#TRP.MetricsSummaryRequest) | optional |  |
| metrics_summary_response | [MetricsSummaryResponse](#TRP.MetricsSummaryResponse) | optional |  |
| key_space_request | [KeySpaceRequest](#TRP.KeySpaceRequest) | optional |  |
| key_space_response | [KeySpaceResponse](#TRP.KeySpaceResponse) | optional |  |
| pcap_slices_request | [PcapSlicesRequest](#TRP.PcapSlicesRequest) | optional |  |
| log_request | [LogRequest](#TRP.LogRequest) | optional |  |
| log_response | [LogResponse](#TRP.LogResponse) | optional |  |
| context_create_request | [ContextCreateRequest](#TRP.ContextCreateRequest) | optional |  |
| context_delete_request | [ContextDeleteRequest](#TRP.ContextDeleteRequest) | optional |  |
| context_start_request | [ContextStartRequest](#TRP.ContextStartRequest) | optional |  |
| context_stop_request | [ContextStopRequest](#TRP.ContextStopRequest) | optional |  |
| context_config_request | [ContextConfigRequest](#TRP.ContextConfigRequest) | optional |  |
| context_config_response | [ContextConfigResponse](#TRP.ContextConfigResponse) | optional |  |
| context_info_request | [ContextInfoRequest](#TRP.ContextInfoRequest) | optional |  |
| context_info_response | [ContextInfoResponse](#TRP.ContextInfoResponse) | optional |  |
| domain_request | [DomainRequest](#TRP.DomainRequest) | optional |  |
| domain_response | [DomainResponse](#TRP.DomainResponse) | optional |  |
| node_config_request | [NodeConfigRequest](#TRP.NodeConfigRequest) | optional |  |
| node_config_response | [NodeConfigResponse](#TRP.NodeConfigResponse) | optional |  |
| async_request | [AsyncRequest](#TRP.AsyncRequest) | optional |  |
| async_response | [AsyncResponse](#TRP.AsyncResponse) | optional |  |
| file_request | [FileRequest](#TRP.FileRequest) | optional |  |
| file_response | [FileResponse](#TRP.FileResponse) | optional |  |
| destination_node | [string](#string) | optional |  |
| probe_id | [string](#string) | optional |  |
| run_async | [bool](#bool) | optional | if run_async = true, then you will immediately get a AsynResponse with a token you can poll |


<a name="TRP.MeterInfo"/>
### MeterInfo
MeterType : information about a particular meter
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [int32](#int32) | required |  |
| type | [MeterInfo.MeterType](#TRP.MeterInfo.MeterType) | required |  |
| topcount | [int32](#int32) | required |  |
| name | [string](#string) | required |  |
| description | [string](#string) | optional |  |
| units | [string](#string) | optional |  |


<a name="TRP.MeterValues"/>
### MeterValues
MeterValues : a timeseries  (meter_id, stat1, stat2, ... statn) 
/     this is rarely used because StatsArray is available .

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| meter | [int32](#int32) | required | metric id , eg Hosts:TotalConnections |
| values | [StatsTuple](#TRP.StatsTuple) | repeated |  |
| total | [int64](#int64) | optional | total of all metric values |
| seconds | [int64](#int64) | optional | total number of seconds in time series |


<a name="TRP.MetricsSummaryRequest"/>
### MetricsSummaryRequest
MetricsSummaryRequest - used to retrieve DB stats

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| metric_name | [string](#string) | required |  |
| totals_only | [bool](#bool) | optional |  Default: true |


<a name="TRP.MetricsSummaryResponse"/>
### MetricsSummaryResponse
MetricsSummaryResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| metric_name | [string](#string) | required |  |
| vals | [StatsTuple](#TRP.StatsTuple) | repeated |  |


<a name="TRP.NameValue"/>
### NameValue


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| name | [string](#string) | required |  |
| value | [string](#string) | optional |  |


<a name="TRP.NodeConfigRequest"/>
### NodeConfigRequest


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| message | [string](#string) | optional |  |
| add_feed | [NodeConfigRequest.IntelFeed](#TRP.NodeConfigRequest.IntelFeed) | optional |  |
| process_new_feed | [NodeConfigRequest.IntelFeed](#TRP.NodeConfigRequest.IntelFeed) | optional |  |
| get_all_nodes | [bool](#bool) | optional |  Default: true |
| query_config | [NameValue](#TRP.NameValue) | repeated |  |


<a name="TRP.NodeConfigRequest.IntelFeed"/>
### NodeConfigRequest.IntelFeed


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| guid | [string](#string) | required | identifying feed group (eg Geo, Badfellas) |
| name | [string](#string) | optional | name |
| download_rules | [string](#string) | optional | xml file with feed update instructions |
| uri | [string](#string) | repeated | individual files in config//.. for FileRequest download |


<a name="TRP.NodeConfigResponse"/>
### NodeConfigResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| domains | [NodeConfigResponse.Node](#TRP.NodeConfigResponse.Node) | repeated |  |
| hubs | [NodeConfigResponse.Node](#TRP.NodeConfigResponse.Node) | repeated |  |
| probes | [NodeConfigResponse.Node](#TRP.NodeConfigResponse.Node) | repeated |  |
| feeds | [string](#string) | repeated |  |
| config_values | [NameValue](#TRP.NameValue) | repeated |  |


<a name="TRP.NodeConfigResponse.Node"/>
### NodeConfigResponse.Node


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [string](#string) | required |  |
| nodetype | [DomainNodeType](#TRP.DomainNodeType) | required |  |
| description | [string](#string) | required |  |
| public_key | [string](#string) | required |  |


<a name="TRP.OKResponse"/>
### OKResponse
OKResponse
/ many messages return an OKResponse indicating success of operation

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| original_command | [int64](#int64) | required | command id of request |
| message | [string](#string) | optional | success message |


<a name="TRP.PcapRequest"/>
### PcapRequest
PcapRequest - retrieve a PCAP
/ Sent directly to each probe rather than to the DB query HUB   
/
/ the flow is PCAP Request for a file -&gt; put a file on the probe &gt; return a token
/    &gt; use that token in FileRequest to download the file from the probe 
/
/ see app notes and examples
/
/  NOTE - only one of the various filters are supported
/  sending &gt; 1 will result in error 
/  
/ Modes
/  1.  nothing set =&gt; PCAP file in contents
/  2.  save_file_prefix set =&gt;  file download token
/  3.  merge_pcap_files =&gt; file download token 
/ 
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| max_bytes | [int64](#int64) | optional |  Default: 100000000 |
| compress_type | [CompressionType](#TRP.CompressionType) | optional |  Default: UNCOMPRESSED |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| save_file_prefix | [string](#string) | optional |  |
| filter_expression | [string](#string) | optional | PCAP filter expression in Trisul Filter format |
| merge_pcap_files | [string](#string) | repeated | list of PCAP files on probe that you need to merge |
| delete_after_merge | [bool](#bool) | optional |  Default: true |
| format | [PcapFormat](#TRP.PcapFormat) | optional |  Default: LIBPCAP |


<a name="TRP.PcapResponse"/>
### PcapResponse
Pcap Response - for small files (&lt;1MB) contents directly contain the PCAP 
/   for larger files, save_file contains a download token for use by FileRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| format | [PcapFormat](#TRP.PcapFormat) | optional |  Default: LIBPCAP |
| compress_type | [CompressionType](#TRP.CompressionType) | optional |  Default: UNCOMPRESSED |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| num_bytes | [int64](#int64) | optional |  |
| sha1 | [string](#string) | optional |  |
| contents | [bytes](#bytes) | optional |  |
| save_file | [string](#string) | optional |  |


<a name="TRP.PcapSlicesRequest"/>
### PcapSlicesRequest
.. response = TimeSlicesResponse
/ get the PCAP METASLICE based info

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| get_total_window | [bool](#bool) | optional |  Default: false |


<a name="TRP.ProbeStatsRequest"/>
### ProbeStatsRequest
ProbeStatsRequest - DOMAIN 
/ retrieve statistics about probe cpu, mem, etc

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| param | [string](#string) | optional |  |


<a name="TRP.ProbeStatsResponse"/>
### ProbeStatsResponse
ProbeStatsResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| instance_name | [string](#string) | required |  |
| connections | [int64](#int64) | required |  |
| uptime_seconds | [int64](#int64) | required |  |
| cpu_usage_percent_trisul | [double](#double) | required |  |
| cpu_usage_percent_total | [double](#double) | required |  |
| mem_usage_trisul | [double](#double) | required |  |
| mem_usage_total | [double](#double) | required |  |
| mem_total | [double](#double) | required |  |
| drop_percent_cap | [double](#double) | required |  |
| drop_percent_trisul | [double](#double) | required |  |
| proc_bytes | [int64](#int64) | optional |  |
| proc_packets | [int64](#int64) | optional |  |
| offline_pcap_file | [string](#string) | optional |  |
| is_running | [bool](#bool) | optional |  |


<a name="TRP.QueryAlertsRequest"/>
### QueryAlertsRequest
QueryAlertsRequest - query alerts in system, can group_by (aggregate) any one field 
/ multiple query fields are treated as AND

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| alert_group | [string](#string) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| sigid | [KeyT](#TRP.KeyT) | optional |  |
| classification | [KeyT](#TRP.KeyT) | optional |  |
| priority | [KeyT](#TRP.KeyT) | optional |  |
| aux_message1 | [string](#string) | optional | matches dispatchmessage1 in AlertT |
| aux_message2 | [string](#string) | optional | matches dispatchmessage2 in AlertT |
| group_by_fieldname | [string](#string) | optional | can group by any field - group by 'sigid' will group results by sigid |
| idlist | [string](#string) | repeated | list of alert ids |
| resolve_keys | [bool](#bool) | optional |  Default: true |
| any_ip | [KeyT](#TRP.KeyT) | optional | search by any_ip (source_dest) |
| any_port | [KeyT](#TRP.KeyT) | optional | search by any_port (source_dest) |
| ip_pair | [KeyT](#TRP.KeyT) | repeated | array of 2 ips |
| message_regex | [string](#string) | optional | searech via regex of the dispatch message |


<a name="TRP.QueryAlertsResponse"/>
### QueryAlertsResponse
QueryAlertsResponse - response 
/ if you used group_by_fieldname then AlertT.occurrances would contain the count

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| alert_group | [string](#string) | required |  |
| alerts | [AlertT](#TRP.AlertT) | repeated | array of matching alerts |


<a name="TRP.QueryFTSRequest"/>
### QueryFTSRequest
FTS
/  query to return docs, docids, and flows based on keyword search
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| fts_group | [string](#string) | required |  |
| keywords | [string](#string) | required |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |


<a name="TRP.QueryFTSResponse"/>
### QueryFTSResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| fts_group | [string](#string) | required |  |
| documents | [DocumentT](#TRP.DocumentT) | repeated |  |


<a name="TRP.QueryResourcesRequest"/>
### QueryResourcesRequest
QueryResourcesRequest - resource queries

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| resource_group | [string](#string) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| uri_pattern | [string](#string) | optional |  |
| userlabel_pattern | [string](#string) | optional |  |
| regex_uri | [string](#string) | repeated |  |
| idlist | [string](#string) | repeated |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |
| any_port | [KeyT](#TRP.KeyT) | optional |  |
| any_ip | [KeyT](#TRP.KeyT) | optional |  |
| ip_pair | [KeyT](#TRP.KeyT) | repeated |  |


<a name="TRP.QueryResourcesResponse"/>
### QueryResourcesResponse
QueryResourceResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| resource_group | [string](#string) | required |  |
| resources | [ResourceT](#TRP.ResourceT) | repeated |  |


<a name="TRP.QuerySessionsRequest"/>
### QuerySessionsRequest
QuerySessions - Query flows 
/   fields filled are treated as AND criteria 
/   See SessionT for description of common query fields

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | optional |  Default: &quot;{99A78737-4B41-4387-8F31-8077DB917336}&quot; |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| key | [string](#string) | optional |  |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| dest_ip | [KeyT](#TRP.KeyT) | optional |  |
| dest_port | [KeyT](#TRP.KeyT) | optional |  |
| any_ip | [KeyT](#TRP.KeyT) | optional | source or dest match |
| any_port | [KeyT](#TRP.KeyT) | optional | source or dest match |
| ip_pair | [KeyT](#TRP.KeyT) | repeated | array of 2 ips |
| protocol | [KeyT](#TRP.KeyT) | optional |  |
| flowtag | [string](#string) | optional | string flow tagger text |
| nf_routerid | [KeyT](#TRP.KeyT) | optional |  |
| nf_ifindex_in | [KeyT](#TRP.KeyT) | optional |  |
| nf_ifindex_out | [KeyT](#TRP.KeyT) | optional |  |
| subnet_24 | [string](#string) | optional | ip /24 subnet  matching |
| subnet_16 | [string](#string) | optional | ip /16 subnet |
| maxitems | [int64](#int64) | optional | maximum number of matching flows to retrieve Default: 100 |
| volume_filter | [int64](#int64) | optional | only retrieve flows &gt; this many bytes (a+z) Default: 0 |
| resolve_keys | [bool](#bool) | optional |  Default: true |
| outputpath | [string](#string) | optional | write results to a file (CSV) on trisul-hub (for very large dumps) |
| idlist | [string](#string) | repeated | array of flow ids , usually from SessionTracker response |


<a name="TRP.QuerySessionsResponse"/>
### QuerySessionsResponse
QuerySessionsResponse 
/  a list of matching flows

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | required |  |
| sessions | [SessionT](#TRP.SessionT) | repeated | matching flows SessionT objects |
| outputpath | [string](#string) | optional | if 'outputpath' set in request, the sessions are here (in CSV format) |


<a name="TRP.ResourceT"/>
### ResourceT
ResourceT : represents a &quot;resource&quot; object 
/ examples DNS records, HTTP URLs, TLS Certificates, extracted file hashes, etc

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time | [Timestamp](#TRP.Timestamp) | required | time resource was seen |
| resource_id | [string](#string) | required | DB id format = 988:0:8388383 |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| uri | [string](#string) | optional | raw resource - uniform resource id ,dns names, http url, etc |
| userlabel | [string](#string) | optional | additional data |
| probe_id | [string](#string) | optional | which probe detected this |


<a name="TRP.SearchKeysRequest"/>
### SearchKeysRequest
SearchkeysRequest - search for keys

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| pattern | [string](#string) | optional |  |
| label | [string](#string) | optional |  |
| keys | [string](#string) | repeated |  |
| offset | [int64](#int64) | optional |  Default: 0 |
| get_totals | [bool](#bool) | optional |  Default: false |


<a name="TRP.SearchKeysResponse"/>
### SearchKeysResponse
SearchKeysResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| keys | [KeyT](#TRP.KeyT) | repeated |  |
| total_count | [int64](#int64) | optional |  |


<a name="TRP.SessionT"/>
### SessionT
SessionT : an IP flow 
/

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_key | [string](#string) | optional | Trisul format eg 06A:C0.A8.01.02:p-0B94_D1.D8.F9.3A:p-0016 |
| session_id | [string](#string) | required | SID once stored in DB 883:3:883488 |
| user_label | [string](#string) | optional | any label assigned by user |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required | start and end time of flow |
| state | [int64](#int64) | optional | flow state (see docs) |
| az_bytes | [int64](#int64) | optional | bytes in A&gt;Z direction, see KeyA&gt;KeyZ |
| za_bytes | [int64](#int64) | optional | bytes in  Z&gt;A direction |
| az_packets | [int64](#int64) | optional | pkts in A&gt;Z direction |
| za_packets | [int64](#int64) | optional | pkts in Z&gt;A direction |
| key1A | [KeyT](#TRP.KeyT) | required | basically IP A End |
| key2A | [KeyT](#TRP.KeyT) | required | Port Z End (can be a string like ICMP00, GRE00, for non TCP/UDP) |
| key1Z | [KeyT](#TRP.KeyT) | required | IP Z end |
| key2Z | [KeyT](#TRP.KeyT) | required | Port Z End |
| protocol | [KeyT](#TRP.KeyT) | required | IP Protocol |
| nf_routerid | [KeyT](#TRP.KeyT) | optional | Netflow only : Router ID |
| nf_ifindex_in | [KeyT](#TRP.KeyT) | optional | Netflow only : Interface Index |
| nf_ifindex_out | [KeyT](#TRP.KeyT) | optional | Netflow only : Interface Index |
| tags | [string](#string) | optional | tags assigned using flow taggers |
| az_payload | [int64](#int64) | optional | AZ payload - actual content transferred |
| za_payload | [int64](#int64) | optional | ZA payload |
| setup_rtt | [int64](#int64) | optional | Round Trip Time for setup : Must have TCPReassmbly enabled on Probe |
| retransmissions | [int64](#int64) | optional | Retransmissiosn total |
| tracker_statval | [int64](#int64) | optional | Metric for flow trackers |
| probe_id | [string](#string) | optional | Probe ID generating this flow |


<a name="TRP.SessionTrackerRequest"/>
### SessionTrackerRequest
SessionTrackerRequest  - query session trackers 
/     session trackers are top-k streaming algorithm for network flows 
/     They are Top Sessions fulfilling a particular preset criterion

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | optional |  Default: &quot;{99A78737-4B41-4387-8F31-8077DB917336}&quot; |
| tracker_id | [int64](#int64) | required | session tracker id Default: 1 |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |


<a name="TRP.SessionTrackerResponse"/>
### SessionTrackerResponse
SessionTrackerResponse - results of tracker
/  returns a list of SessionT  for the matching sessions. 
/  Note: the returned list of SessionT only contains keys (in key format) and the 
/  tracker_statval reprsenting the tracker metric. You need to send further QuerySession
/  request with the session_key to retrive the fullflow

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | required |  |
| sessions | [SessionT](#TRP.SessionT) | repeated | contains session_key and tracker_statval |
| tracker_id | [int64](#int64) | optional |  |


<a name="TRP.StatsArray"/>
### StatsArray
StatsArray : multiple timeseries values (t, v1, v2, v3...vn) 
/    notice we use ts_tv_sec. Most Trisul data have 1 sec resolution.

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| ts_tv_sec | [int64](#int64) | required | tv.tv_sec |
| values | [int64](#int64) | repeated | array of values |


<a name="TRP.StatsTuple"/>
### StatsTuple
StatsTuple : a single timeseries vaue (t,v)

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| ts | [Timestamp](#TRP.Timestamp) | required | ts |
| val | [int64](#int64) | required | value metric |


<a name="TRP.SubscribeCtl"/>
### SubscribeCtl
Subscribe - add a subcription to the Real Time channel

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| ctl | [SubscribeCtl.CtlType](#TRP.SubscribeCtl.CtlType) | required |  |
| type | [SubscribeCtl.StabberType](#TRP.SubscribeCtl.StabberType) | required |  |
| guid | [string](#string) | optional |  |
| key | [string](#string) | optional |  |
| meterid | [int64](#int64) | optional |  |


<a name="TRP.TimeInterval"/>
### TimeInterval
TimeInterval from and to

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| from | [Timestamp](#TRP.Timestamp) | required | start time |
| to | [Timestamp](#TRP.Timestamp) | required | end  time |


<a name="TRP.TimeSlicesRequest"/>
### TimeSlicesRequest
Timeslices - retrieves the backend timeslice details 
/
/ get the METERS METASLICE info 
/ .. response = TimeSlicesResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| get_disk_usage | [bool](#bool) | optional |  Default: false |
| get_all_engines | [bool](#bool) | optional |  Default: false |
| get_total_window | [bool](#bool) | optional |  Default: false |


<a name="TRP.TimeSlicesResponse"/>
### TimeSlicesResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| slices | [TimeSlicesResponse.SliceT](#TRP.TimeSlicesResponse.SliceT) | repeated |  |
| total_window | [TimeInterval](#TRP.TimeInterval) | optional |  |
| context_name | [string](#string) | optional |  |


<a name="TRP.TimeSlicesResponse.SliceT"/>
### TimeSlicesResponse.SliceT


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| name | [string](#string) | optional |  |
| status | [string](#string) | optional |  |
| disk_size | [int64](#int64) | optional |  |
| path | [string](#string) | optional |  |
| available | [bool](#bool) | optional |  |


<a name="TRP.Timestamp"/>
### Timestamp


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| tv_sec | [int64](#int64) | required |  |
| tv_usec | [int64](#int64) | optional |  Default: 0 |


<a name="TRP.TopperTrendRequest"/>
### TopperTrendRequest
TopperTrendRequest - raw top-K at each topper snapshot interval
/ can use this to see &quot;Top apps over 1 Week&quot;

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | optional |  Default: 0 |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |


<a name="TRP.TopperTrendResponse"/>
### TopperTrendResponse
TopperTrendResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | required |  |
| keytrends | [KeyStats](#TRP.KeyStats) | repeated | timeseries - ts, (array of key stats) for each snapshot interval |


<a name="TRP.UpdateKeyRequest"/>
### UpdateKeyRequest
UpdatekeysRequest
/ Response = OKResponse or ErrorResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| keys | [KeyT](#TRP.KeyT) | repeated | key  : if you set both key and label, the DB label will be updated |



<a name="TRP.AuthLevel"/>
### AuthLevel
Enums
/  Auth Level

| Name | Number | Description |
| ---- | ------ | ----------- |
| ADMIN | 1 |  |
| BASIC_USER | 2 |  |
| FORENSIC_USER | 3 |  |
| BLOCKED_USER | 4 |  |

<a name="TRP.CompressionType"/>
### CompressionType
Compression: Used by PCAP or other content requests

| Name | Number | Description |
| ---- | ------ | ----------- |
| UNCOMPRESSED | 1 |  |
| GZIP | 2 |  |

<a name="TRP.DomainNodeType"/>
### DomainNodeType


| Name | Number | Description |
| ---- | ------ | ----------- |
| HUB | 0 |  |
| PROBE | 1 |  |
| CONFIG | 2 |  |
| ROUTER | 3 |  |
| WEB | 4 |  |
| MONITOR | 5 |  |

<a name="TRP.DomainOperation"/>
### DomainOperation


| Name | Number | Description |
| ---- | ------ | ----------- |
| GETNODES | 1 |  |
| HEARTBEAT | 2 |  |
| REGISTER | 3 |  |

<a name="TRP.Message.Command"/>
### Message.Command


| Name | Number | Description |
| ---- | ------ | ----------- |
| HELLO_REQUEST | 1 |  |
| HELLO_RESPONSE | 2 |  |
| OK_RESPONSE | 3 |  |
| ERROR_RESPONSE | 5 |  |
| COUNTER_GROUP_TOPPER_REQUEST | 6 |  |
| COUNTER_GROUP_TOPPER_RESPONSE | 7 |  |
| COUNTER_ITEM_REQUEST | 8 |  |
| COUNTER_ITEM_RESPONSE | 9 |  |
| PCAP_REQUEST | 14 |  |
| PCAP_RESPONSE | 15 |  |
| SEARCH_KEYS_REQUEST | 18 |  |
| SEARCH_KEYS_RESPONSE | 19 |  |
| COUNTER_GROUP_INFO_REQUEST | 20 |  |
| COUNTER_GROUP_INFO_RESPONSE | 21 |  |
| SESSION_TRACKER_REQUEST | 22 |  |
| SESSION_TRACKER_RESPONSE | 23 |  |
| UPDATE_KEY_REQUEST | 32 |  |
| UPDATE_KEY_RESPONSE | 33 |  |
| QUERY_SESSIONS_REQUEST | 34 |  |
| QUERY_SESSIONS_RESPONSE | 35 |  |
| PROBE_STATS_REQUEST | 38 |  |
| PROBE_STATS_RESPONSE | 39 |  |
| QUERY_ALERTS_REQUEST | 44 |  |
| QUERY_ALERTS_RESPONSE | 45 |  |
| QUERY_RESOURCES_REQUEST | 48 |  |
| QUERY_RESOURCES_RESPONSE | 49 |  |
| GREP_REQUEST | 60 |  |
| GREP_RESPONSE | 61 |  |
| KEYSPACE_REQUEST | 70 |  |
| KEYSPACE_RESPONSE | 71 |  |
| TOPPER_TREND_REQUEST | 72 |  |
| TOPPER_TREND_RESPONSE | 73 |  |
| STAB_PUBSUB_CTL | 80 |  |
| QUERY_FTS_REQUEST | 90 |  |
| QUERY_FTS_RESPONSE | 91 |  |
| TIMESLICES_REQUEST | 92 |  |
| TIMESLICES_RESPONSE | 93 |  |
| DELETE_ALERTS_REQUEST | 94 |  |
| METRICS_SUMMARY_REQUEST | 95 |  |
| METRICS_SUMMARY_RESPONSE | 96 |  |
| PCAP_SLICES_REQUEST | 97 |  |
| SERVICE_REQUEST | 101 |  |
| SERVICE_RESPONSE | 102 |  |
| CONFIG_REQUEST | 103 |  |
| CONFIG_RESPONSE | 104 |  |
| LOG_REQUEST | 105 |  |
| LOG_RESPONSE | 106 |  |
| CONTEXT_CREATE_REQUEST | 108 |  |
| CONTEXT_DELETE_REQUEST | 109 |  |
| CONTEXT_START_REQUEST | 110 |  |
| CONTEXT_STOP_REQUEST | 111 |  |
| CONTEXT_INFO_REQUEST | 112 |  |
| CONTEXT_INFO_RESPONSE | 113 |  |
| CONTEXT_CONFIG_REQUEST | 114 |  |
| CONTEXT_CONFIG_RESPONSE | 115 |  |
| DOMAIN_REQUEST | 116 |  |
| DOMAIN_RESPONSE | 117 |  |
| NODE_CONFIG_REQUEST | 118 |  |
| NODE_CONFIG_RESPONSE | 119 |  |
| ASYNC_REQUEST | 120 |  |
| ASYNC_RESPONSE | 121 |  |
| FILE_REQUEST | 122 |  |
| FILE_RESPONSE | 123 |  |
| SUBSYSTEM_INIT | 124 |  |
| SUBSYSTEM_EXIT | 125 |  |

<a name="TRP.MeterInfo.MeterType"/>
### MeterInfo.MeterType
types of meters 
from TrisulAPI

| Name | Number | Description |
| ---- | ------ | ----------- |
| VT_INVALID | 0 |  |
| VT_RATE_COUNTER_WITH_SLIDING_WINDOW | 1 | this for top-N type counters |
| VT_COUNTER | 2 | basic counter, stores val in the raw |
| VT_COUNTER_WITH_SLIDING_WINDOW | 3 | use this for top-N type counters |
| VT_RATE_COUNTER | 4 | rate counter stores val/sec |
| VT_GAUGE | 5 | basic gauge |
| VT_GAUGE_MIN_MAX_AVG | 6 | gauge with 3 additional min/avg/max cols (auto) |
| VT_AUTO | 7 | automatic (eg, min/max/avg/stddev/) |
| VT_RUNNING_COUNTER | 8 | running counter, no delta calc |
| VT_AVERAGE | 9 | average of samples, total/sampl uses 32bt|32bit |

<a name="TRP.PcapFormat"/>
### PcapFormat
Pcap: format

| Name | Number | Description |
| ---- | ------ | ----------- |
| LIBPCAP | 1 | normal libpcap format *.pcap |
| UNSNIFF | 2 |  |
| LIBPCAPNOFILEHEADER | 3 | libpcap but without the pcap file header |

<a name="TRP.SubscribeCtl.CtlType"/>
### SubscribeCtl.CtlType


| Name | Number | Description |
| ---- | ------ | ----------- |
| CT_SUBSCRIBE | 0 |  |
| CT_UNSUBSCRIBE | 1 |  |

<a name="TRP.SubscribeCtl.StabberType"/>
### SubscribeCtl.StabberType


| Name | Number | Description |
| ---- | ------ | ----------- |
| ST_COUNTER_ITEM | 0 |  |
| ST_ALERT | 1 |  |
| ST_FLOW | 2 |  |
| ST_TOPPER | 3 |  |





<a name="scalar-value-types"/>
## Scalar Value Types

| .proto Type | Notes | C++ Type | Java Type | Python Type |
| ----------- | ----- | -------- | --------- | ----------- |
| <a name="double"/> double |  | double | double | float |
| <a name="float"/> float |  | float | float | float |
| <a name="int32"/> int32 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead. | int32 | int | int |
| <a name="int64"/> int64 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead. | int64 | long | int/long |
| <a name="uint32"/> uint32 | Uses variable-length encoding. | uint32 | int | int/long |
| <a name="uint64"/> uint64 | Uses variable-length encoding. | uint64 | long | int/long |
| <a name="sint32"/> sint32 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s. | int32 | int | int |
| <a name="sint64"/> sint64 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s. | int64 | long | int/long |
| <a name="fixed32"/> fixed32 | Always four bytes. More efficient than uint32 if values are often greater than 2^28. | uint32 | int | int |
| <a name="fixed64"/> fixed64 | Always eight bytes. More efficient than uint64 if values are often greater than 2^56. | uint64 | long | int/long |
| <a name="sfixed32"/> sfixed32 | Always four bytes. | int32 | int | int |
| <a name="sfixed64"/> sfixed64 | Always eight bytes. | int64 | long | int/long |
| <a name="bool"/> bool |  | bool | boolean | boolean |
| <a name="string"/> string | A string must always contain UTF-8 encoded or 7-bit ASCII text. | string | String | str/unicode |
| <a name="bytes"/> bytes | May contain any arbitrary sequence of bytes. | string | ByteString | str |
