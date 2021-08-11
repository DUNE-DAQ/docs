# Getting Started

## Define information structure to be monitored 

Before using opmonlib it is important to understand and define what needs to be monitored.

Monotorable objects can then be captured in a `schema` file to create C++ structs using `moo`. Documentation and instructions on generating schema data structures and using moo can be found here:


* [Schema](https://brettviren.github.io/moo/dunedaq-appfwk-schema.html)

* [Moo](https://brettviren.github.io/moo/buildsys.html#intro)

Examples of how to write schemas can be found [here](https://github.com/DUNE-DAQ/timing/tree/feature/op_mon/schema/timing). In general each `.jsonnet` file contains definitions of types, and the objects to be monitored using these types. Each `schema` file will generate a C++ header file containing the structures which hold the monitoring data, as defined in the `.jsonnet` file. Typically each module may only need one struct to hold its monitoring information; however it is possible to create multiple nested structs within a schema, which are filled by the same module, as demonstrated by the timing module.

## Filling and collecting structures

Once the information structures have been generated, we need to fill them with data and collect the information for monitoring. 

For `opmonlib` to collect the relevant information from the DAQ module, define the public `get_info()` function in the DAQ module header file as the following:
```
void get_info(opmonlib::InfoCollector& ci, int level) override;
```
The `InfoCollector` class is used collect the information structures using the `add` function. The `level` defines the level of information the user wants to monitor (e.g. default, detailed, debug, etc.). Default information is defined as `level=0`. An example of how the `get_info` function is implemented in `FakeCardReader.hpp` in the `readout` [module](https://github.com/DUNE-DAQ/readout/blob/develop/plugins/FakeCardReader.cpp):
```
void
FakeCardReader::get_info(opmonlib::InfoCollector& ci, int level=0) {
  fakecardreaderinfo::Info fcr;

  fcr.packets = m_packet_count_tot.load();
  fcr.new_packets = m_packet_count.exchange(0);
  ci.add(fcr);
}
```
here the information structure `fcr` is filled with the relevant data members, and then added to the `InfoCollector` for monitoring. In this case the filling and collecting is implemented in the same instance.


**It is important** at this point to consider whether it is necessary to separate filling from collecting. For example, `opmonlib` may call `get_info()` for information to be collected at a faster rate than the hardware can handle. In this case, one may want to separate the filling and collecting of information into two separate threads. 

The timing module provides an example of how one can do this using its `InfoGatherer` shown [here](https://github.com/DUNE-DAQ/timing/blob/feature/op_mon/src/InfoGatherer.hpp). `InfoGatherer` provides a template class which can fill different types of information structures. Examples of this are implemented in `TimingHardwareManagerPDI.hpp`:
```
  // monitoring
  InfoGatherer<pdt::timingmon::TimingPDIMasterTLUMonitorData> m_master_monitor_data_gatherer;
  virtual void gather_master_monitor_data(InfoGatherer<pdt::timingmon::TimingPDIMasterTLUMonitorData>& gatherer);

  InfoGatherer<pdt::timingmon::TimingEndpointFMCMonitorData> m_endpoint_monitor_data_gatherer;
  virtual void gather_endpoint_monitor_data(InfoGatherer<pdt::timingmon::TimingEndpointFMCMonitorData>& gatherer);
```

## Testing

The configuration of `opmonlib` is currently managed through the environment variables: `DUNEDAQ_OPMON_INTERVAL` and `DUNEDAQ_OPMON_LEVEL`. These can be seen further in `Application.cpp`:
```
  setenv("DUNEDAQ_OPMON_INTERVAL",    "10",0);
  setenv("DUNEDAQ_OPMON_LEVEL",  "1",0);
```
here `DUNEDAQ_OPMON_INTERVAL` sets the interval in seconds between each instance of calling `get_info` (currently set to 10 seconds), and `DUNEDAQ_OPMON_LEVEL` allows the user to define the level for `get_info` (currently set to 1). 

Note: To disable operational monitoring set the interval to 0 seconds. 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu Apr 8 09:47:34 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/opmonlib/issues](https://github.com/DUNE-DAQ/opmonlib/issues)_
</font>
