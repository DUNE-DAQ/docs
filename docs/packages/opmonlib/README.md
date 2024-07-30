# opmonlib - Operational Monitoring library

### Desctription


*opmonlib* allows applications to collect and publish operational monitoring data.
The package contains two basic output plugins, to stdout or to file.

The behavior of the output is controlled via the URI that is passed to the InfoManager constructor.

For the two plugins privided within opmonlib the following URI can be used:

- stdout://flat
outputs one line for each variable
- stdout://formatted
outputs formatted json objects
- stdout://compact
outputs a json object in one line
- file:///file/path/file_name.out

[Instructions for DAQ module users](Instructions-for-DAQ-module-users.md)

### Building and running examples (_under construction_)




-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu May 20 13:19:05 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/opmonlib/issues](https://github.com/DUNE-DAQ/opmonlib/issues)_
</font>
