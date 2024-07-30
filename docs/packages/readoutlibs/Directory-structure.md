# Directory structure of this repo
This repository is structured as follows:

* `cmake`

* `docs`

* `include/readoutlibs`

  * `concepts`

  * `models`

  * `utils`

* `schema/readoutlibs`

* `scripts/performance`

* `test`

* `unittest`

## Where to find the code
The main code of the readoutlibs package is located in `include/readoutlibs`. This code is meant to be reusable by other packages. The goal is to have everything in `include/readoutlibs` in a generic form such that other frontends can be implemented with it.
To do so, new frontend datatypes can be defined and the generic templated classes instantiated with them. 
The organisation of `include/readoutlibs` itself separates "concepts", "models" and "utils", each in subdirectories of the same names. 

Concepts are interfaces or abstract classes. Their implementations are models in the nomenclature of this package.
All models in `models` inherit from a class in `concepts`, and usually the names of the two classes are related.
Readout facilities use the capabilities of generic concepts and can be instantiated (through the use of templating) with models that implement them.
This makes it easy to implement new models with different properties that are necessary for different frontend types.
A good example for this is the latency buffer which buffers raw data received from the frontend and provides it to the request handler that can look up chunks based on timestamps.
The file [`LatencyBufferConcept.hpp`](https://github.com/DUNE-DAQ/readoutlibs/blob/develop/include/readoutlibs/concepts/LatencyBufferConcept.hpp) in `include/readoutlibs/concepts` defines some properties that have to be implemented, for example access to front and back or the ability to add and remove elements.
There are several latency buffer implementations in `include/readoutlibs/models`.
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
Lastly, `scripts/performance` contains code and configurations to do thread pinning of the application.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Thu Dec 2 16:11:37 2021 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/readoutlibs/issues](https://github.com/DUNE-DAQ/readoutlibs/issues)_
</font>
