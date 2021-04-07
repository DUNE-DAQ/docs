# Interfaces between DAQ objects
This page is hosting a description of how the different objects inside a DAQ process are supposed to interface to each other. At the moment nothing is definitive, this is simply reflecting the code status.

A DAQ Process is a collection of DAQModules that are connected by object called Queues. 
There are no restriction on the number of Modules a queue is connected to so the overall graph can scale to a high degree of complexity. 

Documentations on the specific objects can be find at these links:

* [DAQModules](DAQModules.md)

* [Queues](Queue-interfaces.md)

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Apr 7 11:56:00 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/appfwk/issues](https://github.com/DUNE-DAQ/appfwk/issues)_
</font>
