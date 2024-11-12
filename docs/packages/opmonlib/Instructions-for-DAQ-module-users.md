# Getting Started

## Define information structure to be monitored 

Before using opmonlib it is important to understand and define what needs to be monitored.

Monitorable objects can then be captured in a `schema` file to create C++ structs using `ProtoBuf`. 
Documentation and instructions on generating schema data structures and using ProtoBuf can be found in the [ProtoBuf website](https://protobuf.dev/programming-guides/proto3/). 
Relevant pages also include the description of the C++ API.


In general each `.protobuf` file contains definitions of blocks that are published as single units.
Each `schema` file will generate a C++ header file containing the structures which hold the monitoring data, as defined in the `.proto` file. 
Typically each module may only need one struct to hold its monitoring information; however it is possible to create multiple nested structs within a schema, which are filled by the same module.

It is preferred to organise the protobuf schemas in the following way:


 * put the opmon related schemas in `schema/opmon` inside your repository

 * try to group the schemas so that the schema used by the same modules are in the same file; the name of the file should match the name of the module

 * as protobuf generates a lot of code, there might be conflicts with our code - protect the generated code with an additional `opmon` namespace

Here is an example, taken from the `DFOModule.proto`, which contains the schemas used by DFOModule plugin in dfmodules. 
```
syntax = "proto3";

package dunedaq.dfmodules.opmon;

// regular metric published byt the DFO
message DFOInfo {
  // counters 
  uint64 tokens_received = 1;
  uint64 decisions_received = 2;
  uint64 decisions_sent = 3;

  // time management of the decision thread
  uint64 waiting_for_decision = 10 ; // Time spent waiting on Trigger Decisions, in microseconds
  uint64 deciding_destination = 11 ; // Time spent making a decision on the receving DF app, in microseconds
  uint64 forwarding_decision = 12  ; // Time spent sending the Trigger Decision to TRBs, in microseconds

  // time management of the token thread
  uint64 waiting_for_token = 15 ; // Time spent waiting in token thread for tokens, in microseconds
  uint64 processing_token = 16 ; // Time spent in token thread updating data structure, in microseconds
}

// these counters are published separately for each trigger type
message TriggerInfo {
  uint64 received = 1;
  uint64 completed = 2;
}
```

### Valid types
As a generic schema language, `ProtoBuf` allows you to use simple types, but also lists, maps, etc.
Be aware that apart from basic types and nested messages, other quantities are ignored by the monitoring system.
An `OpMonEntry` message is generated whenever a structure with at least one publishable field is passed to the `publish` method, see next section.

## Filling and collecting structures
The `ProtoBuf` C++ API guide describes how to fill the structures you created. 
In order to publish the metric, the object has to be created from within a `MonitorableObject`, see [the header file](https://github.com/DUNE-DAQ/opmonlib/blob/mroda/protobuf/include/opmonlib/MonitorableObject.hpp).
In particular, a `DAQModule` *is* a `MonitorableObject`. 
Two main functions are relevant for publishing:
```C++
void publish( google::protobuf::Message &&,
     	        CustomOrigin && co = {},
              OpMonLevel l = to_level(EntryOpMonLevel::kDefault) ) const noexcept ;
virtual void generate_opmon_data(opmon_level) {return;}
```


* `publish` takes a ProtoBuf schema object, it timestamps it with the time of the function call, it serializes it (synchronously) and publishes it (asynchronously) via one of the configured OpMonFacilities. This function can be called at anytime. 

* `generate_opmon_data` is a function which the monitoring system calls regularly (order of seconds). Its default behaviour is 'null'. Every developer can freely implement this in their MonitorableObject in order to avoid setting up a thread to generate information regularly. Specific implementations are expected to call the `publish` function to actually publish the metric.

### Example
An example of metric publication is
```C++
void DFOModule::generate_opmon_data()  {

  opmon::DFOInfo info;
  info.set_tokens_received( m_received_tokens.exchange(0) );
  info.set_decisions_sent(m_sent_decisions.exchange(0));
  info.set_decisions_received(m_received_decisions.exchange(0));
  info.set_waiting_for_decision(m_waiting_for_decision.exchange(0));
  info.set_deciding_destination(m_deciding_destination.exchange(0));
  info.set_forwarding_decision(m_forwarding_decision.exchange(0));
  info.set_waiting_for_token(m_waiting_for_token.exchange(0));
  info.set_processing_token(m_processing_token.exchange(0));
  publish( std::move(info) );

  std::lock_guard<std::mutex>	guard(m_trigger_mutex);
  for ( auto & [type, counts] : m_trigger_counters ) {
    opmon::TriggerInfo ti;
    ti.set_received(counts.received.exchange(0));
    ti.set_completed(counts.completed.exchange(0));
    auto name = dunedaq::trgdataformats::get_trigger_candidate_type_names()[type];
    publish( std::move(ti), {{"type", name}} );
   }
}
```

### Details and good practices about the optional arguments 
Optional arguments of the `publish` function, allow you to:


* specify a level of priority associated to the metric

* add additional custom information on the source of the metric, in the form of a `map<string, string>`, where the key is the type of the source, e.g. channel, and the second is the value, e.g. 4345

* extend the `opmon_id` of the caller `MonitorableObject` for the specific metric with more detailed information on the source of this metric

The `OpMonLevel` is a priority level designed to control the quantity of metrics generated by a tree. As a default, all messages are published. The lower the level, the higher the priority. 
They system can decide to entirely disable the metric publication regardless of the OpMonLevel. 
The system already provides some values to specify the `OpMonLevel` via an enum:
```C++
enum class EntryOpMonLevel : OpMonLevel {
    kTopPriority     = std::numeric_limits<OpMonLevel>::min(),
    kEventDriven     = std::numeric_limits<OpMonLevel>::max()/4,
    kDefault         = std::numeric_limits<OpMonLevel>::max()/2,
    kLowestPrioriry  = std::numeric_limits<OpMonLevel>::max()-1
  };

```
but users are welcome to fill the gaps with whatever number they are happy to associate with their metric.

The usage of a custom origin is designed to provide information that is unrelated to software stack.
While the software stack might change (e.g, the name of an application or of a module can change because of configuration), some information like a crate number or a channel are hardware related and they are independent of the software stack that provides this information. 
Examples of valid tags to be used in the custom origins are: server name, channel, links, etc. 
The value of a tag should not grow indefinitely for retrival efficiency in the database. So, things like run number should not become a custom origin. 
Adding information like application name or session in the custom origin is discouraged because it would be redundant. 
In the example above, you see an usage example where `TriggerInfo` contains counters grouped by trigger type.

## Registering sub components for your DAQModule

In order to work correctly, each `MonitorableObject` has to be part of a monitoring tree, i.e. every `MonitorablreObject` has to be registered to the chain. 
This is done via the method
```C++
void register_node( std::string name, new_node_ptr ) ;
```
If not registered, the metric is not completely lost, an ERS error will be generated reporting the usage of an unconfigured reporting system. 

The metrics generated by the child will have an `opmon_id` in the form `parent_opmon_id.child_name`. 
The registration does not imply ownership of the child by the parent, as internally only weak pointers are utilised. 
If the child is destroyed, its pointer will eventually be removed from the chain. 

`DAQModule`s will be automatically registered by the application framework and developers have to write their code assuming that the module is registered in the monitoring tree from the moment of its creation. 
On the other hand, developers have to take care of the registration of subcomonents living inside their modules.

An example of registration is:
```C++
void DFOModule::receive_trigger_complete_token(const dfmessages::TriggerDecisionToken& token) {
  if (m_dataflow_availability.count(token.decision_destination) == 0) {
    TLOG_DEBUG(TLVL_CONFIG) << "Creating dataflow availability struct for uid " << token.decision_destination;
    auto entry = m_dataflow_availability[token.decision_destination] =
      std::make_shared<TriggerRecordBuilderData>(token.decision_destination, m_busy_threshold, m_free_threshold);
    register_node(token.decision_destination, entry);
  } 
}
```
Notice that here the registraion is event driven: something triggers the creation of an object and it's possible to register the object at anytime. 
Of course a more static approach is possible too.

The registration does not imply ownership, so in order to unregister an object you just need to delete the shared pointer. 

## Testing

The configuration of `opmonlib` is currently managed through the environment variables: `DUNEDAQ_OPMON_INTERVAL` and `DUNEDAQ_OPMON_LEVEL`. These can be seen further in `Application.cpp`:
```
  setenv("DUNEDAQ_OPMON_INTERVAL",    "10",0);
  setenv("DUNEDAQ_OPMON_LEVEL",  "1",0);
```
here, `DUNEDAQ_OPMON_INTERVAL` sets the interval in seconds between each instance of calling `generate_opmon_data` (currently defaulting to 10 seconds), and `DUNEDAQ_OPMON_LEVEL` allows the user to define the level for `generatre_opmon_data` (currently set to 1). 



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Michal Rigan_

_Date: Tue Aug 20 16:08:35 2024 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/opmonlib/issues](https://github.com/DUNE-DAQ/opmonlib/issues)_
</font>
