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

### Building and running examples:


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: glehmannmiotto_

_Date: Wed Mar 10 16:34:35 2021 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/opmonlib/issues](https://github.com/DUNE-DAQ/opmonlib/issues)_
</font>
