# fdreadoutmodules - Readout plugin collection for the far detector
Collection of readout specializations.

## Modules provided

`fdreadoutmodules` provides several `DAQModule`s that are listed here:

* `FDDataHandlerModule`: Abstraction for one link of the DAQ. It receives input from a frontend as raw data and buffers it in memory. Data can be retrieved through a request/response mechanism (requests are of the type `DataRequest` and the response is a `Fragment`). Additionaly, data can be recorded for a specified amount of time and written to disk through a high performance mechanism. The module can handle different frontends and some support additional features. 

* `FDFakeCardReaderModule`: This module emulates a frontend that pushes raw data to a `FDDataHandlerModule` by reading raw data from a file and repeating it over and over, while updating the timestamps of the data. A slowdown factor can be set to run at a lower speed which makes it possible to run the whole DAQ on less powerful systems.

* `DataRecorderModule`: Receives data from an input queue and writes it to disk. It supports writing with `O_DIRECT`, making it more performant in some scenarios.

* `FragmentConsumer`: Consumes fragments and does some sanity checks of the data (for now just for WIB data) like checking the timestamps of the data against the requested window.

* `ErroredFrameConsumer`: Consumes error frames, this module is used as long as there is no other consumer for this information.

* `TimeSyncConsumer`: Consumes timesync messages (and nothing more). Can be used in the standalone readout app.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Tue Jul 16 08:45:08 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/fdreadoutmodules/issues](https://github.com/DUNE-DAQ/fdreadoutmodules/issues)_
</font>
