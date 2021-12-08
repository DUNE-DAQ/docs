# fdreadoutlibs - Far Detector readout libraries
Collection of Far Detector FrontEnd specific readout specializations. This includes type definitions to be used with the implementations in `readoutlibs` and frontend specific specializations (i.e. frame processors or software hit finding). It is the glue between `readoutlibs` and `readoutmodules` that specifies types and implementations for the use of `readoutlibs` that can then be imported by `readoutmodules` to be initialized in the `DataLinkHandler` module.

## Building and setting up the workarea

How to clone and build DUNE DAQ packages, including `readout`, is covered in [the daq-buildtools instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/). For examples on how to run the standalone readout app, take a look at the `readoutmodules` documentation.

## Frontends and features provided by `fdreadoutlibs`
The following frontends and features are provided by this package:

* *Daphne*: Frame processor and request handler to be used with the SkipList latency buffer.

* *SSP*: Only frame processor

* *WIB*: Frame processor for `WIB`, software and hardware `WIB` TPs. Implementation of avx based software hit finding (software tpg) for `WIB`

* *WIB2*: Only frame processor


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: floriangroetschla_

_Date: Mon Nov 22 15:27:06 2021 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/fdreadoutlibs/issues](https://github.com/DUNE-DAQ/fdreadoutlibs/issues)_
</font>
