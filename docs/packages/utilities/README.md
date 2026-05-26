# utilities: Utility classes for dunedaq

## Current Tools


* `Resolver` -- Performs DNS SRV record lookups

* `ReusableThread` -- Wrapper around a `std::thread` for executing short-lived tasks

* [`WorkerThread`](WorkerThread-Usage-Notes/) -- Wrapper around a `std::jthread` for long-lived tasks (e.g. DAQModule work loops) 

### API Diagram

![Class Diagrams](https://github.com/DUNE-DAQ/utilities/raw/develop/docs/utilities.png)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Mon Jul 21 10:33:45 2025 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/utilities/issues](https://github.com/DUNE-DAQ/utilities/issues)_
</font>
