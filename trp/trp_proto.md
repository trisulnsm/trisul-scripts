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



<a name="TRP.AlertT"/>
### AlertT
/////////////////////////////////
AlertT

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| sensor_id | [int64](#int64) | optional |  |
| time | [Timestamp](#TRP.Timestamp) | required |  |
| alert_id | [string](#string) | required |  |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| sigid | [KeyT](#TRP.KeyT) | optional |  |
| classification | [KeyT](#TRP.KeyT) | optional |  |
| priority | [KeyT](#TRP.KeyT) | optional |  |
| dispatch_time | [Timestamp](#TRP.Timestamp) | optional |  |
| dispatch_message1 | [string](#string) | optional |  |
| dispatch_message2 | [string](#string) | optional |  |
| occurrances | [int64](#int64) | optional |  Default: 1 |
| group_by_key | [string](#string) | optional |  |
| probe_id | [string](#string) | optional |  |
| alert_status | [string](#string) | optional |  |
| acknowledge_flag | [int64](#int64) | optional |  |


<a name="TRP.AsyncRequest"/>
### AsyncRequest
///////////////////////////////
AsyncRequest
     response taken from original (if ready) or not_ready flag set

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| token | [int64](#int64) | required |  |
| request_message | [string](#string) | optional |  |


<a name="TRP.AsyncResponse"/>
### AsyncResponse
//////////////////////////////////
AsyncResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| token | [int64](#int64) | required |  |
| response_message | [string](#string) | optional |  |
| response | [Message](#TRP.Message) | optional |  |


<a name="TRP.ContextConfigRequest"/>
### ContextConfigRequest
///////////////////////////////
ContextConfigRequest - start stop status 
 OK or ERROR response 
 Status = OK if running with PID etc in message text

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| profile | [string](#string) | optional |  |
| params | [string](#string) | optional |  |
| push_config_blob | [bytes](#bytes) | optional |  |
| query_config | [NameValue](#TRP.NameValue) | repeated |  |
| set_config_values | [NameValue](#TRP.NameValue) | repeated |  |


<a name="TRP.ContextConfigResponse"/>
### ContextConfigResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| profile | [string](#string) | optional |  |
| params | [string](#string) | optional |  |
| pull_config_blob | [bytes](#bytes) | optional |  |
| config_blob | [bytes](#bytes) | optional |  |
| endpoints_flush | [string](#string) | repeated |  |
| endpoints_query | [string](#string) | repeated |  |
| endpoints_pub | [string](#string) | repeated |  |
| config_values | [NameValue](#TRP.NameValue) | repeated |  |
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
///////////////////////////////
ContextRequest  - Context methods 
 response Ok or Error, follow up with ContextInfo to print details

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| clone_from | [string](#string) | optional |  |


<a name="TRP.ContextDeleteRequest"/>
### ContextDeleteRequest
///////////////////////////////
ContextDelete  : initialize 
     reset data only ..

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| reset_data | [bool](#bool) | optional |  |


<a name="TRP.ContextInfoRequest"/>
### ContextInfoRequest
///////////////////////////////
ContextInfo : one or all contexts
 use is_init to prime with config

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | optional |  |
| get_size_on_disk | [bool](#bool) | optional |  Default: false |


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


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| mode | [string](#string) | optional |  |
| background | [bool](#bool) | optional |  |
| pcap_path | [string](#string) | optional |  |
| run_tool | [string](#string) | optional |  |
| tool_ids_config | [string](#string) | optional |  |
| tool_av_config | [string](#string) | optional |  |


<a name="TRP.ContextStopRequest"/>
### ContextStopRequest


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| run_tool | [string](#string) | optional |  |


<a name="TRP.CounterGroupInfoRequest"/>
### CounterGroupInfoRequest
//////////////////////////////////
/ CounterGroupInfoRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | optional |  |
| get_meter_info | [bool](#bool) | optional |  Default: false |


<a name="TRP.CounterGroupInfoResponse"/>
### CounterGroupInfoResponse
////////////////////////////////
/ CounterGroupInfoResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| group_details | [CounterGroupT](#TRP.CounterGroupT) | repeated |  |


<a name="TRP.CounterGroupT"/>
### CounterGroupT


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| guid | [string](#string) | required |  |
| name | [string](#string) | required |  |
| bucket_size | [int64](#int64) | optional |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| topper_bucket_size | [int64](#int64) | optional |  |
| meters | [MeterInfo](#TRP.MeterInfo) | repeated |  |


<a name="TRP.CounterGroupTopperRequest"/>
### CounterGroupTopperRequest
////////////////////////////
CounterGroupTopperRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | optional |  Default: 0 |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| time_instant | [Timestamp](#TRP.Timestamp) | optional |  |
| flags | [int64](#int64) | optional |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |


<a name="TRP.CounterGroupTopperResponse"/>
### CounterGroupTopperResponse
////////////////////////////
CounterGroupTopperResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | required |  |
| sysgrouptotal | [int64](#int64) | optional |  |
| keys | [KeyT](#TRP.KeyT) | repeated |  |


<a name="TRP.CounterItemRequest"/>
### CounterItemRequest
////////////////////////////
CounterItemRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | optional |  |
| key | [KeyT](#TRP.KeyT) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| volumes_only | [int64](#int64) | optional |  Default: 0 |


<a name="TRP.CounterItemResponse"/>
### CounterItemResponse
////////////////////////////
CounterItemResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| key | [KeyT](#TRP.KeyT) | required |  |
| totals | [StatsArray](#TRP.StatsArray) | optional |  |
| stats | [StatsArray](#TRP.StatsArray) | repeated |  |


<a name="TRP.DeleteAlertsRequest"/>
### DeleteAlertsRequest


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
| message_regex | [string](#string) | optional |  |


<a name="TRP.DocumentT"/>
### DocumentT
/////////////////////////////////
DocumentT

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| dockey | [string](#string) | required |  |
| fts_attributes | [string](#string) | optional |  |
| fullcontent | [string](#string) | optional |  |
| flows | [DocumentT.Flow](#TRP.DocumentT.Flow) | repeated |  |
| probe_id | [string](#string) | optional |  |


<a name="TRP.DocumentT.Flow"/>
### DocumentT.Flow


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time | [Timestamp](#TRP.Timestamp) | required |  |
| key | [string](#string) | required |  |


<a name="TRP.DomainRequest"/>
### DomainRequest


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
////////////////////////////
Error

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| original_command | [int64](#int64) | required |  |
| error_code | [int64](#int64) | required |  |
| error_message | [string](#string) | required |  |


<a name="TRP.FileRequest"/>
### FileRequest
//////////////////////////////////
FileRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| uri | [string](#string) | required |  |
| position | [int64](#int64) | required |  |
| params | [string](#string) | optional |  |
| context_name | [string](#string) | optional |  |
| delete_on_eof | [bool](#bool) | optional |  Default: false |


<a name="TRP.FileResponse"/>
### FileResponse
///////////////////////////////
FileResponse
     one chunk at at time, Trisul has slightly inefficient File Transfer
     for very large files, since most files are data feeds  &lt; 100MB fine for now

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| uri | [string](#string) | required |  |
| eof | [bool](#bool) | required |  |
| position | [int64](#int64) | optional |  |
| content | [bytes](#bytes) | optional |  |
| request_params | [string](#string) | optional |  |
| context_name | [string](#string) | optional |  |


<a name="TRP.GrepRequest"/>
### GrepRequest
/////////////////////////////////
GrepRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| flowcutoff_bytes | [int64](#int64) | optional |  |
| pattern_hex | [string](#string) | optional |  |
| pattern_text | [string](#string) | optional |  |
| pattern_file | [string](#string) | optional |  |
| md5list | [string](#string) | repeated |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |


<a name="TRP.GrepResponse"/>
### GrepResponse
//////////////////////////////////
GrepResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| sessions | [SessionT](#TRP.SessionT) | repeated |  |
| hints | [string](#string) | repeated |  |
| probe_id | [string](#string) | optional |  |


<a name="TRP.HelloRequest"/>
### HelloRequest
////////////////////////////
Hello

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| station_id | [string](#string) | required |  |
| message | [string](#string) | optional |  |


<a name="TRP.HelloResponse"/>
### HelloResponse


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| station_id | [string](#string) | required |  |
| station_id_request | [string](#string) | optional |  |
| message | [string](#string) | optional |  |
| local_timestamp | [int64](#int64) | optional |  |


<a name="TRP.KeySpaceRequest"/>
### KeySpaceRequest
/////////////////////////////////
KeySpaceRequest

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
| from_key | [KeyT](#TRP.KeyT) | required |  |
| to_key | [KeyT](#TRP.KeyT) | required |  |


<a name="TRP.KeySpaceResponse"/>
### KeySpaceResponse
//////////////////////////////////
KeySpaceResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | optional |  |
| hits | [KeyT](#TRP.KeyT) | repeated |  |


<a name="TRP.KeyStats"/>
### KeyStats


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| key | [KeyT](#TRP.KeyT) | required |  |
| meters | [MeterValues](#TRP.MeterValues) | repeated |  |


<a name="TRP.KeyT"/>
### KeyT


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| key | [string](#string) | optional |  |
| readable | [string](#string) | optional |  |
| label | [string](#string) | optional |  |
| description | [string](#string) | optional |  |
| metric | [int64](#int64) | optional |  |


<a name="TRP.LogRequest"/>
### LogRequest
///////////////////////////////
LogRequest  - want log file

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
| log_lines | [string](#string) | repeated |  |


<a name="TRP.Message"/>
### Message


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
| run_async | [bool](#bool) | optional |  |


<a name="TRP.MeterInfo"/>
### MeterInfo


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


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| meter | [int32](#int32) | required |  |
| values | [StatsTuple](#TRP.StatsTuple) | repeated |  |
| total | [int64](#int64) | optional |  |
| seconds | [int64](#int64) | optional |  |


<a name="TRP.MetricsSummaryRequest"/>
### MetricsSummaryRequest
///////////////////////////////
MetricsSummaryRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| metric_name | [string](#string) | required |  |
| totals_only | [bool](#bool) | optional |  Default: true |


<a name="TRP.MetricsSummaryResponse"/>
### MetricsSummaryResponse
///////////////////////////////
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
| guid | [string](#string) | required |  |
| name | [string](#string) | optional |  |
| download_rules | [string](#string) | optional |  |
| uri | [string](#string) | repeated |  |


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
////////////////////////////
OK

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| original_command | [int64](#int64) | required |  |
| message | [string](#string) | optional |  |


<a name="TRP.PcapRequest"/>
### PcapRequest
////////////////////////////
PcapReqiest
 NOTE - only one of the various filters are supported
 sending &gt; 1 will result in error 
 
Modes
 1.  nothing set =&gt; PCAP file in contents
 2.  save_file_prefix set =&gt;  file download token
 3.  merge_pcap_files =&gt; file download token

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| max_bytes | [int64](#int64) | optional |  Default: 100000000 |
| compress_type | [CompressionType](#TRP.CompressionType) | optional |  Default: UNCOMPRESSED |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| save_file_prefix | [string](#string) | optional |  |
| filter_expression | [string](#string) | optional |  |
| merge_pcap_files | [string](#string) | repeated |  |
| delete_after_merge | [bool](#bool) | optional |  Default: true |
| format | [PcapFormat](#TRP.PcapFormat) | optional |  Default: LIBPCAP |


<a name="TRP.PcapResponse"/>
### PcapResponse
//////////////////////////////////
FileredDatagaramResponse

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


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| get_total_window | [bool](#bool) | optional |  Default: false |


<a name="TRP.ProbeStatsRequest"/>
### ProbeStatsRequest
///////////////////////////////
ProbeStatsRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| context_name | [string](#string) | required |  |
| param | [string](#string) | optional |  |


<a name="TRP.ProbeStatsResponse"/>
### ProbeStatsResponse
///////////////////////////////
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
/////////////////////////////////
QueryAlertsRequest

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
| aux_message1 | [string](#string) | optional |  |
| aux_message2 | [string](#string) | optional |  |
| group_by_fieldname | [string](#string) | optional |  |
| idlist | [string](#string) | repeated |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |
| any_ip | [KeyT](#TRP.KeyT) | optional |  |
| any_port | [KeyT](#TRP.KeyT) | optional |  |
| ip_pair | [KeyT](#TRP.KeyT) | repeated |  |
| message_regex | [string](#string) | optional |  |


<a name="TRP.QueryAlertsResponse"/>
### QueryAlertsResponse
//////////////////////////////////
QueryAlertsResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| alert_group | [string](#string) | required |  |
| alerts | [AlertT](#TRP.AlertT) | repeated |  |


<a name="TRP.QueryFTSRequest"/>
### QueryFTSRequest


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
/////////////////////////////////
 QueryResourcesRequest

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
//////////////////////////////////
QueryResourceResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| resource_group | [string](#string) | required |  |
| resources | [ResourceT](#TRP.ResourceT) | repeated |  |


<a name="TRP.QuerySessionsRequest"/>
### QuerySessionsRequest
////////////////////////////////
QuerySessions - any of the fields can be filled
                all the fields filled are treated as AND criteria

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | optional |  Default: &quot;{99A78737-4B41-4387-8F31-8077DB917336}&quot; |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |
| key | [string](#string) | optional |  |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| dest_ip | [KeyT](#TRP.KeyT) | optional |  |
| dest_port | [KeyT](#TRP.KeyT) | optional |  |
| any_ip | [KeyT](#TRP.KeyT) | optional |  |
| any_port | [KeyT](#TRP.KeyT) | optional |  |
| ip_pair | [KeyT](#TRP.KeyT) | repeated |  |
| protocol | [KeyT](#TRP.KeyT) | optional |  |
| flowtag | [string](#string) | optional |  |
| nf_routerid | [KeyT](#TRP.KeyT) | optional |  |
| nf_ifindex_in | [KeyT](#TRP.KeyT) | optional |  |
| nf_ifindex_out | [KeyT](#TRP.KeyT) | optional |  |
| subnet_24 | [string](#string) | optional |  |
| subnet_16 | [string](#string) | optional |  |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| volume_filter | [int64](#int64) | optional |  Default: 0 |
| resolve_keys | [bool](#bool) | optional |  Default: true |
| outputpath | [string](#string) | optional |  |
| idlist | [string](#string) | repeated |  |


<a name="TRP.QuerySessionsResponse"/>
### QuerySessionsResponse
//////////////////////////////////
QuerySessionsResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | required |  |
| sessions | [SessionT](#TRP.SessionT) | repeated |  |
| outputpath | [string](#string) | optional |  |


<a name="TRP.ResourceT"/>
### ResourceT
/////////////////////////////////
ResourceT

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| time | [Timestamp](#TRP.Timestamp) | required |  |
| resource_id | [string](#string) | required |  |
| source_ip | [KeyT](#TRP.KeyT) | optional |  |
| source_port | [KeyT](#TRP.KeyT) | optional |  |
| destination_ip | [KeyT](#TRP.KeyT) | optional |  |
| destination_port | [KeyT](#TRP.KeyT) | optional |  |
| uri | [string](#string) | optional |  |
| userlabel | [string](#string) | optional |  |
| probe_id | [string](#string) | optional |  |


<a name="TRP.SearchKeysRequest"/>
### SearchKeysRequest
////////////////////////////////////
SearchkeysRequest

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
///////////////////////////////////
SearchKeysResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| keys | [KeyT](#TRP.KeyT) | repeated |  |
| total_count | [int64](#int64) | optional |  |


<a name="TRP.SessionT"/>
### SessionT


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_key | [string](#string) | optional |  |
| session_id | [string](#string) | required |  |
| user_label | [string](#string) | optional |  |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| state | [int64](#int64) | optional |  |
| az_bytes | [int64](#int64) | optional |  |
| za_bytes | [int64](#int64) | optional |  |
| az_packets | [int64](#int64) | optional |  |
| za_packets | [int64](#int64) | optional |  |
| key1A | [KeyT](#TRP.KeyT) | required |  |
| key2A | [KeyT](#TRP.KeyT) | required |  |
| key1Z | [KeyT](#TRP.KeyT) | required |  |
| key2Z | [KeyT](#TRP.KeyT) | required |  |
| protocol | [KeyT](#TRP.KeyT) | required |  |
| nf_routerid | [KeyT](#TRP.KeyT) | optional |  |
| nf_ifindex_in | [KeyT](#TRP.KeyT) | optional |  |
| nf_ifindex_out | [KeyT](#TRP.KeyT) | optional |  |
| tags | [string](#string) | optional |  |
| az_payload | [int64](#int64) | optional |  |
| za_payload | [int64](#int64) | optional |  |
| setup_rtt | [int64](#int64) | optional |  |
| retransmissions | [int64](#int64) | optional |  |
| tracker_statval | [int64](#int64) | optional |  |
| probe_id | [string](#string) | optional |  |


<a name="TRP.SessionTrackerRequest"/>
### SessionTrackerRequest
//////////////////////////////////
SessionTrackerRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | optional |  Default: &quot;{99A78737-4B41-4387-8F31-8077DB917336}&quot; |
| tracker_id | [int64](#int64) | required |  Default: 1 |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| time_interval | [TimeInterval](#TRP.TimeInterval) | required |  |
| resolve_keys | [bool](#bool) | optional |  Default: true |


<a name="TRP.SessionTrackerResponse"/>
### SessionTrackerResponse
////////////////////////////////
SessionTrackerResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| session_group | [string](#string) | required |  |
| sessions | [SessionT](#TRP.SessionT) | repeated |  |
| tracker_id | [int64](#int64) | optional |  |


<a name="TRP.StatsArray"/>
### StatsArray


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| ts_tv_sec | [int64](#int64) | required |  |
| values | [int64](#int64) | repeated |  |


<a name="TRP.StatsTuple"/>
### StatsTuple


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| ts | [Timestamp](#TRP.Timestamp) | required |  |
| val | [int64](#int64) | required |  |


<a name="TRP.SubscribeCtl"/>
### SubscribeCtl
////////////////////////////////
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


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| from | [Timestamp](#TRP.Timestamp) | required |  |
| to | [Timestamp](#TRP.Timestamp) | required |  |


<a name="TRP.TimeSlicesRequest"/>
### TimeSlicesRequest


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
////////////////////////////
TopperTrendRequest

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | optional |  Default: 0 |
| maxitems | [int64](#int64) | optional |  Default: 100 |
| time_interval | [TimeInterval](#TRP.TimeInterval) | optional |  |


<a name="TRP.TopperTrendResponse"/>
### TopperTrendResponse
////////////////////////////
TopperTrendResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| meter | [int64](#int64) | required |  |
| keytrends | [KeyStats](#TRP.KeyStats) | repeated |  |


<a name="TRP.UpdateKeyRequest"/>
### UpdateKeyRequest
///////////////////////////////////////////
/ UpdatekeysRequest
/ Response = OKResponse or ErrorResponse

| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| counter_group | [string](#string) | required |  |
| keys | [KeyT](#TRP.KeyT) | repeated |  |



<a name="TRP.AuthLevel"/>
### AuthLevel


| Name | Number | Description |
| ---- | ------ | ----------- |
| ADMIN | 1 |  |
| BASIC_USER | 2 |  |
| FORENSIC_USER | 3 |  |
| BLOCKED_USER | 4 |  |

<a name="TRP.CompressionType"/>
### CompressionType


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


| Name | Number | Description |
| ---- | ------ | ----------- |
| VT_INVALID | 0 |  |
| VT_RATE_COUNTER_WITH_SLIDING_WINDOW | 1 |  |
| VT_COUNTER | 2 |  |
| VT_COUNTER_WITH_SLIDING_WINDOW | 3 |  |
| VT_RATE_COUNTER | 4 |  |
| VT_GAUGE | 5 |  |
| VT_GAUGE_MIN_MAX_AVG | 6 |  |
| VT_AUTO | 7 |  |
| VT_RUNNING_COUNTER | 8 |  |
| VT_AVERAGE | 9 |  |

<a name="TRP.PcapFormat"/>
### PcapFormat


| Name | Number | Description |
| ---- | ------ | ----------- |
| LIBPCAP | 1 |  |
| UNSNIFF | 2 |  |
| LIBPCAPNOFILEHEADER | 3 |  |

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
