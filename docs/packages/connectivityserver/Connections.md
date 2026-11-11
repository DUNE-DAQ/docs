# Connection Fields Reference Guide

## Overview

The `Connection` namedtuple is the core data structure in the DUNE DAQ connectivity service. It represents metadata about network connections between DAQ applications and subsystems. This document provides comprehensive documentation of all Connection fields and their values, as observed in running DUNE DAQ systems.

### Connection Named Tuple Definition

```python
Connection = namedtuple(
    "Connection",
    ["uri", "data_type", "capacity", "connection_type", "time", "hostname"],
)
```
The following subsections explain the application and scope of each of these fields


## `uri: str`

Defines the network endpoint address where this connection is available, as published by applications. This is formatted as

```
<protocol>://<host>:<port>
```

### Examples
- `tcp://gp04-srv-029.cern.ch:30006`
- `tcp://192.168.1.100:1234`
- `rest://localhost:5000`

### Notes
- The raw URI is stored as-is and never modified
- The resolver then attempts to resolve the hostname and caches the result for 1 hour
- See `hostname` field for DNS resolution behavior

## `hostname: str | None`

The resolved physical hostname of the connection endpoint, resolved from the `uri`.

### Resolution Strategy



1. **System DNS Resolver** (primary, always attempted)
   - Converts IP addresses and DNS names to physical hostnames



2. **Kubernetes Discovery** (secondary, only if `KUBECONFIG` is set)
   - Looks up pod IP addresses in the cluster
   - Matches pod to its node and retrieves node hostname
   - Only attempted for cluster-DNS names (`.svc`, `.pod` suffixes)

#### Notes and examples
 - Should resolution fail, an empty string is stored.
 - Resolved hostnames are cached in memory for **1 hour**

##### Example - host URI
 - `tcp://np04-srv-029.cern.ch:30006` - Raw received URI
 - `np04-srv-029` - hostname
 - `tcp://np04-srv-029:30006` - resolved URI

##### Example - pod URI
 - `tcp://np04-pod-12.default.pod.cluster.local:30006` - Raw received URI
 - `np04-srv-029` - hostname
 - `tcp://np04-srv-029:30006` - resolved URI


## Endpoint type
Identifies the type of data transmitted through this connection. This is crucial for routing, serialization/deserialization, and monitoring. This is a mandatory field.

The follwowing table lists the currently defined types


| Category | Types |
|----------|-------|
| Raw Detector Data | CRTBernFrame<br/>CRTGrenobleFrame<br/>DAPHNEEthFrame<br/>DAPHNEEthStreamFrame<br/>PDSFrame<br/>PDSStreamFrame<br/>TDEEthFrame<br/>WIBEthFrame<br/>HSIFrame |
| Trigger Data | TPSet<br/>TriggerActivity<br/>TriggerCandidate<br/>TriggerDecision<br/>TriggerDecisionToken<br/>TriggerPrimitiveVector |
| Request/Response | DataRequest<br/>TRMonRequest |
| Status and Synchronisation | TimeSync<br/>DataflowStatus<br/>DataflowStatusRequest |
| Data Selection and Recording | Fragment<br/>TriggerRecord<br/>TRBCompletion<br/>TriggerInhibit |
| Control | RunControlMessage |

## Connection type (ZMQ mapped)

Specifies the ZeroMQ messaging pattern used for this connection. It is defined as either 0 for `kSendRecv` (synchronous) or `kPubSub` (publisher-subscriber model).

| Type          | kSendRecv (0)               | kPubSub (1) |
|-              |-                            |-            |
| Pattern       | Point-to-Point              | Broadcast   |
| ZeroMQ Socket | PUSH/PULL or REQUEST/REPLY  | PUB/SUB     |
| Use Cases     | Ordered flow                | Broadcast   |

## `capacity: uint32_t`

Defines the maximum number of messages/objects that can be queued in the connection's buffer before the sender experiences backpressure. This represents the queue size in the underlying ZeroMQ socket or equivalent messaging layer.

When a connection's queue reaches capacity:
- kSendRecv - sender is blocked and will not resume until space is available
- kPubSub - publisher never blocks, oldest messages are dropped to make room

### Assigned values
 - `0` - Pass-through with no buffering
 - `11` - latency critical
 - `1000` - Moderate-volume requests, status, and control messages
 - `10000` - Data paths with buffering to handle rate variations
 - `100000` - Throughput prioritised

### Configuration Examples
The following examples are copied from [ehn1daqconfigs](https://gitlab.cern.ch/dune-daq/online/ehn1-daqconfigs/-/blob/develop/defaults/connections.data.xml#L454-480)
```xml
<obj class="QueueDescriptor" id="df-tokens-q">
 <attr name="uid_base" type="string" val="dataflow_token_"/>
 <attr name="queue_type" type="enum" val="kFollyMPMCQueue"/>
 <attr name="capacity" type="u32" val="11"/>
 <attr name="data_type" type="string" val="TriggerDecisionToken"/>
</obj>

<obj class="QueueDescriptor" id="data-req-queue-desc">
 <attr name="uid_base" type="string" val="internal_data_requests_for_"/>
 <attr name="queue_type" type="enum" val="kFollySPSCQueue"/>
 <attr name="capacity" type="u32" val="1000"/>
 <attr name="data_type" type="string" val="DataRequest"/>
</obj>

<obj class="QueueDescriptor" id="fa-input">
 <attr name="uid_base" type="string" val="internal_fragments_"/>
 <attr name="queue_type" type="enum" val="kFollyMPMCQueue"/>
 <attr name="capacity" type="u32" val="100000"/>
 <attr name="data_type" type="string" val="Fragment"/>
</obj>

<obj class="QueueDescriptor" id="tp-input">
 <attr name="uid_base" type="string" val="tp_input_"/>
 <attr name="queue_type" type="enum" val="kFollyMPMCQueue"/>
 <attr name="capacity" type="u32" val="2000000"/>
 <attr name="data_type" type="string" val="TriggerPrimitiveVector"/>
</obj>
```


## `time: datetime`
Timestamp recording when the connection was registered or last updated with the connectivity service. Uses the ISO 8601 format, defined as with an example as
```
YYYY-MM-DDTHH:MM:SS.microseconds
2026-11-10T12:25:38.893805
```


## Web Display
The connectivity service displays all active connections in an HTML table at the root URL (`/`). The table shows one row per connection across all active partitions, with columns for each Connection field:

| Column | Source | Description |
|--------|--------|-------------|
| **Application** | Connection key (uid) | Unique identifier for this connection |
| **URI** | Connection.uri | Raw network endpoint (e.g., `tcp://gp04-srv-029:30006`) |
| **Resolved URI** | Connection.hostname | Resolved physical hostname via DNS/Kubernetes |
| **Endpoint type** | Connection.data_type | Type of data transmitted (see below) |
| **Capacity** | Connection.capacity | Queue buffer size limit |
| **Connection type (ZMQ mapped)** | Connection.connection_type | Messaging pattern (0=kSendRecv, 1=kPubSub) |
| **Last updated time** | Connection.time | Registration timestamp; text turns red when expired (>TTL) |


**Color Coding:** Entries displayed in red text indicate they have exceeded the Entry TTL (default 10 seconds).

## Summary Table: Connection Fields at a Glance
| Field | Type | Values | Examples | Role |
|-------|------|--------|----------|------|
| `uri` | str | URI scheme+host+port | `tcp://node:30030` | Network address |
| `hostname` | str | FQDN or resolved name | `np04-srv-029.cern.ch` | Resolved address for display |
| `data_type` | str | int | `TimeSync`, `Fragment`, `TPSet` | "What data?" |
| `capacity` | u32 | 0, 11, 100, 1K, 10K, 100K | 10000 typical | Queue buffer size |
| `connection_type` | int | 0 or 1 | 0=point-to-point, 1=broadcast | "How transmitted?" |
| `time` | datetime | ISO 8601 timestamp | `2026-11-10T12:25:38.893805` | When registered/updated |



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: PawelPlesniak_

_Date: Wed Nov 11 00:42:54 2026 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/connectivityserver/issues](https://github.com/DUNE-DAQ/connectivityserver/issues)_
</font>
