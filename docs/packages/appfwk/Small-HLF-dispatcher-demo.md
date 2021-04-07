# Small HLF dispatcher demo
28-Apr-2020, KAB: the idea for this small system is to demonstrate one way that we might deliver data to High-Level Filter (HLF) processes.  To keep things simple, we'll say that we start with Trigger Record (TR) data is just a list of 32-bit unsigned integers.

This system would have two types of DAQProcesses.

* the first would be a data-dispatcher type of process that listens for data requests from HLF processes, delivers the data for individual Trigger Records one at a time, and receives the 'analysis results' (as simplistic as we want) back from the HLF process
    * initially the Dispatcher could generate random data internally, and later, it could possibly read data from disk
    * similarly, the Dispatcher could initially throw the analysis results away, but later it might write them to disk

* the second type of process would be an HLF app, which would request TR data from the Dispatcher, pretend to do something with it, and then send fake results back to the Dispatcher.

A nice starting point for this demo system would be to have one Dispatcher process and two HLF processes.  We can say that each of these three processes would be created by hand (e.g. in separate shell windows), the Dispatcher would be given a Start transition first, then the two HLF processes would each be started (in any order).  Stopping would be done in the reverse order (HLF processes Stopped first, then the Dispatcher).

I'll think more about the internals of these two types of processes next.  And try to create a diagram.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Apr 7 11:56:00 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/appfwk/issues](https://github.com/DUNE-DAQ/appfwk/issues)_
</font>
