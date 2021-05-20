# erses README
## erses - ERS output stream inserting ERS issues directly into elastic search
This ERS output stream implementation takes ERS issues, transforms them into nlohmann::json objects and injects them directly into an elastic search database instance. The database connection string is specified as a parameter to the erses stream. At CERN the connection string is _dunedaqutilities/erses_.

### Configuration
The erses plugin is configured through the ERS settings. Users that want make use of it need to define/extend the following ERS environment variables:


1. Tell ERS to load the erses plugin. The liberses.so shared library shall be in the LD_LIBRARY_PATH:

_export  DUNEDAQ_ERS_STREAM_LIBS=erses_



2. Se the partition name. The partition name allows to clearly distinguish the origin of the ERS messages, thus avoiding mixing information from different DAQ instances:

_export DUNEDAQ_PARTITION=ChooseYourPartitionName_



3. Extend the ERS variables which define the output streams to be used for Issues of different severities:
  
_export DUNEDAQ_ERS_INFO"erstrace,throttle(30,100),lstdout,erses(dunedaqutilities/erses)"_

_export DUNEDAQ_ERS_WARNING="erstrace,throttle(30,100),lstderr,erses(dunedaqutilities/erses)"_

_export DUNEDAQ_ERS_ERROR="erstrace,throttle(30,100),lstderr,erses(dunedaqutilities/erses)"_

_export DUNEDAQ_ERS_FATAL="erstrace,lstderr,erses(dunedaqutilities/erses)"_

### Dependencies
This package depends on nlohmann_json and cpr. 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: glehmannmiotto_

_Date: Wed May 19 09:17:52 2021 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/erses/issues](https://github.com/DUNE-DAQ/erses/issues)_
</font>
