# daqpytools
Set of importable tools used to simplify DAQ development in python.


## Scope
This provides a set of tools that are used in python applications, along with their unit tests. Currently, the following tools are defined
 - logging - [code](https://github.com/DUNE-DAQ/daqpytools/tree/develop/src/daqpytools/logging), [wiki](https://github.com/DUNE-DAQ/daqpytools/wiki/Logging)

## Indended use case
This repo will serve as the indended source of distribution standard tooling. Any python tool that is used by multiple repositories should be defined here.

## Setup instructions
For general users, no setup is required - when developing your python applications, it is sufficient to include e.g.
```python
from daqpytools.logging.logger import get_daq_logger
log = get_daq_logger(...)
```
For developers, see the developer wiki.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Oct 22 15:35:25 2025 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
