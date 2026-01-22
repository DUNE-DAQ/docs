# datahandlinglibs - Generic data handling software and utilities 
Generic implementation for DUNE DAQ data handling, used in readout, trigger, hsi, ....
## Building and setting up the workarea

How to clone and build DUNE DAQ packages, including `datahandlinglibs`, is covered in [the daq-buildtools instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/). For some sample examples that demonstrate how to use `datahandlinglibs` check out the documentation of `datahandlinglibs`.
 
## A Deeper Look Into Readout: Functional Elements

### Data-flow Diagram (DFD)
The functional elements are seen on the following DFD. Color codes indicate the ownership (or responsibility) of the DAQ subsystems: <span style="color:blue">Dataflow (=blue)</span> and <span style="color:red">Upstream DAQ (=red)</span>.
![functional-elements](https://cernbox.cern.ch/index.php/s/YmXmHC7LpsCjGjT/download)

### Domains
Individual domains represent a substantially different path of the incoming data, including some sort of data interpretation, transformation, formatting, or buffering. Functional elements marked with _italicized_ text.



1. **Data processing domain** (**Input**: data, **Output**: processing results): The readout is responsible for _generating trigger primitives_ from raw data, and _format_ these TPs to the agreed data-format. After this, the TPs can be _buffered_ and _streamed_ for other subsystems (most importantly, to Dataselection).


2. **Raw Streaming domain** (**Input**: data, **Output**: error/calib stream): The DAQ needs to interpret incoming data and find possible problems and errors with and within data (e.g.: timestamp continuity violation, data integrity, invalid headers, front-end specific error flags). Calibration flags in form of headers are also inside the front-end data frames. In case these flags are found, some data need to be _formatted_ (e.g.: expanded based on channels ) then _streamed_ to a configured destination (e.g.: local raw binary files or appfwk queues).


3. **Requested Data domain** (**Input**: data and data requests -[dfmessages::DataRequest](https://github.com/DUNE-DAQ/dfmessages/blob/develop/include/dfmessages/DataRequest.hpp)-, **Output**: special data requests to other functional elements and requested data -[daqdataformats::Fragment](https://github.com/DUNE-DAQ/daqdataformats/blob/develop/include/daqdataformats/Fragment.hpp)-): This domains contains the conventional "triggered" readout mode. Requested data are _extracted_ from the latency buffers and _routed_ to the appropriate destinations. Special requests (e.g.: recording) may be routed to different domains' functional elements, and data leaving the buffer may be intercepted if needed (e.g.: stream to store).


4. **Recorded Data domain** (**Input**: data, "record" requests, **Output**: recorded data, metadata of data store, transfer acknowledgements and notifications): In case of a `record(O(seconds))` request, data leaving the latency buffer are streamed to a transient data store, which is usually local to the readout unit. The recorded data are transferred to other DAQ subsystems with the help of additional metadata, notifications, and acknowledgements.

### Definitions


1. Latency Buffer: A container that temporarily stores data, and has certain attributes that ensures search-ability based on a lookup criteria. A notable example for this, is the lookup based on the timestamp, where the timestamp can be converted to an exact position in the buffer if the "timestamp continuity" attribute is ensured in the buffer.

## Looking into the directories

At the top level, the datahandlinglibs package uses the same directory structure as other DUNE DAQ packages as described in [the daq-cmake documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-cmake/). However, due its large number of files, additional subdirectories have been added to organize them. This approach is covered [here](Directory-structure.md).



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Giovanna Lehmann Miotto_

_Date: Sat Aug 10 14:29:25 2024 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/datahandlinglibs/issues](https://github.com/DUNE-DAQ/datahandlinglibs/issues)_
</font>
