# Functional elements

This package implements the majority of functional elements of the Upstream DAQ's Readout subsystem.

## Data-flow Diagram (DFD)
The functional elements are seen on the following DFD. Color codes indicate the ownership (or responsibility) of the DAQ subsystems: <span style="color:blue">Dataflow (=blue)</span> and <span style="color:red">Upstream DAQ (=red)</span>.
![functional-elements](https://cernbox.cern.ch/index.php/s/YmXmHC7LpsCjGjT/download)

## Domains
Individual domains represent a substantially different path of the raw data, including some sort of data interpretation, transformation, formatting, or buffering. Functional elements marked with _italicized_ text.



1. **Trigger Primitive (TP) handling domain** (**Input**: raw data, **Output**: TPs): The readout is responsible for _generating trigger primitives_ from raw data, and _format_ these TPs to the agreed data-format. After this, the TPs can be _buffered_ and _streamed_ for other subsystems (most importantly, to Dataselection).


2. **Raw Streaming domain** (**Input**: raw data, **Output**: raw/calib stream): The readout needs to interpret raw data and find possible problems and errors with and withing data (e.g.: timestamp continuity violation, data integrity, invalid headers, front-end specific error flags). Calibration flags in form of headers are also inside the front-end data frames. In case these flags are found, some data need to be _formatted_ (e.g.: expanded based on channels ) then _streamed_ to a configured destination (e.g.: local raw binary files or appfwk queues).


3. **Requested Data domain** (**Input**: raw data and data requests -[dfmessages::DataRequest](https://github.com/DUNE-DAQ/dfmessages/blob/develop/include/dfmessages/DataRequest.hpp)-, **Output**: special data requests to other functional elements and requested data -[dataformats::Fragment](https://github.com/DUNE-DAQ/dataformats/blob/develop/include/dataformats/Fragment.hpp)-): This domains contains the conventional "triggered" readout mode. Data from the front-end are _processed and routed_ to the appropriate destinations: either to the Raw Streaming domain (2) or to the raw data buffer (Latency Buffer). Incoming _requests are handled_ via accessing the data buffer then match and extract the requested data for the request. Special requests (e.g.: recording) may be routed to different domains' functional elements, and data leaving the buffer may be intercepted if needed (e.g.: stream to store).


4. **Recorded Data domain** (**Input**: raw data, "record" requests, **Output**: recorded data, metadata of data store, transfer acknowledgements and notifications): In case of a `record(O(seconds))` request, data leaving the latency buffer are streamed to a transient data store, which is usually local to the readout unit. The recorded data are transferred to other DAQ subsystems with the help of additional metadata, notifications, and acknowledgements.

## Definitions


1. Latency Buffer: A container that temporarily stores the raw data, and has certain attributes that ensures search-ability based on a lookup criteria. A notable example for this, is the lookup based on the timestamp, where the timestamp can be converted to an exact position in the buffer if the "timestamp continuity" attribute is ensured in the buffer.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: roland-sipos_

_Date: Wed Apr 7 09:33:37 2021 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/readout/issues](https://github.com/DUNE-DAQ/readout/issues)_
</font>
