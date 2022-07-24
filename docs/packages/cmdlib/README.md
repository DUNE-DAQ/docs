# cmdlib - Interfaces for commanded objects
Details about commands and commanded object can be found under the [User's Guide](User-Guide.md).

### Building and running examples:


* create a software work area following instructions at https://dune-daq-sw.readthedocs.io/en/latest/ .

### Using the stdinCommandFacility
There is a really simple and basic implementation that comes with the package.
The stdinCommandFacility reads the available commands from a file, then one can
execute these command by typing their IDs on stdin:

    daq_application -c stdin://${CMDLIB_SHARE}/config/cmd.json

![Demo](https://cernbox.cern.ch/index.php/s/BxvvU0PlPuyHjla/download)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Giovanna Lehmann Miotto_

_Date: Thu Jul 14 18:18:42 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/cmdlib/issues](https://github.com/DUNE-DAQ/cmdlib/issues)_
</font>
