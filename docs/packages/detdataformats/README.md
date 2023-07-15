# DUNE Detectors Data Formats

This package contains general-purpose bitfields of detector raw data and utilities used to decode them. For related code which treats _specific_ parts of the DAQ, there are the following packages: [fddetdataformats](https://dune-daq-sw.readthedocs.io/en/latest/packages/fddetdataformats) for the far detector, [nddetdataformats](https://dune-daq-sw.readthedocs.io/en/latest/packages/nddetdataformats) for the near detector, and [trgdataformats](https://dune-daq-sw.readthedocs.io/en/latest/packages/trgdataformats) for the trigger. In general, each kind of detector data can be conveniently decoded via a class with the name of the form `<datatype>Frame` found in a public header file called `<datatype>Frame.hpp`, where values like timestamps and ADC values can be easily retrieved via getter functions. Additionally, for some kinds of data, Python bindings are available.   

In this package you can find:


* `DetID`: [`DetID`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/DetID.hpp) is basically an enhanced `enum` used to describe which of the various subdetectors in the DUNE DAQ are the source of data

* `DAQHeader`: [`DAQHeader`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/DAQHeader.hpp) is a `struct` which provides a common header for every FrontEnd electronics board

* `DAQEthHeader`: [`DAQEthHeader`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/DAQEthHeader.hpp) is a `struct` which provides a common header for every FrontEnd electronics board sending data over ethernet

* `HSIFrame`: [`HSIFrame`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/hsi/HSIFrame.hpp) describes the bitfield of data from the Hardware Signals Interface





-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Mon Apr 24 09:48:51 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/detdataformats/issues](https://github.com/DUNE-DAQ/detdataformats/issues)_
</font>
