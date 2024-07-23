# Directory structure of this repo
This repository is structured as follows:

* `cmake`

* `config`

* `docs`

* `include/datahandlinglibs`

  * `concepts`

  * `models`

  * `utils`

* `schema/datahandlinglibs`

* `scripts`

* `test`

* `unittest`

## Where to find the code
The main code of the datahandlinglibs package is located in `include/datahandlinglibs`. This code is meant to be reusable by other packages. The goal is to have everything in `include/datahandlinglibs` in a generic form such that other frontends can be implemented with it.
To do so, new frontend datatypes can be defined and the generic templated classes instantiated with them. 
The organisation of `include/datahandlinglibs` itself separates "concepts", "models" and "utils", each in subdirectories of the same names. 

Concepts are interfaces or abstract classes. Their implementations are models in the nomenclature of this package.
All models in `models` inherit from a class in `concepts`, and usually the names of the two classes are related.
Readout facilities use the capabilities of generic concepts and can be instantiated (through the use of templating) with models that implement them.
This makes it easy to implement new models with different properties that are necessary for different frontend types.
A good example for this is the latency buffer which buffers raw data received from the frontend and provides it to the request handler that can look up chunks based on timestamps.
The file [`LatencyBufferConcept.hpp`](https://github.com/DUNE-DAQ/datahandlinglibs/blob/develop/include/datahandlinglibs/concepts/LatencyBufferConcept.hpp) in `include/datahandlinglibs/concepts` defines some properties that have to be implemented, for example access to front and back or the ability to add and remove elements.
There are several latency buffer implementations in `include/datahandlinglibs/models`.
The different latency buffer implementations have different requirements for different frontend types. 
One uses a binary search and requires that the chunks which are written to it are already sorted, i.e. the timestamps of chunks only increase.
The implementation can use this fact to make pushing and popping from the queue constant time operations and use a binary search to find and element for a given timestamp.
If data can come in unordered, the skip list can be used as it can insert elements in any order.
The tradeoff here is reduced performance.

When a readout unit is created, the models to use are defined and can be interchanged.

`utils` contains code that provides functionality which is not directly related or exclusive to readout applications.

`schema/readout` contains the jsonnet schema files used for code generation with moo. They define structures for the configuration of the application and info structs for the operational monitoring.

## Testing
`test` contains configs generated with this script and some standalone test applications.
In `unittest` one can very unsurprisingly find unit tests for the readout.
Lastly, `scripts/` and 'config/' contains code and configurations to do thread pinning of the application.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Tue Jul 16 10:10:45 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/datahandlinglibs/issues](https://github.com/DUNE-DAQ/datahandlinglibs/issues)_
</font>
