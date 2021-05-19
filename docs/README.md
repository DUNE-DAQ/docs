# DUNE DAQ Software Documentation Home

```{toctree}
:caption: Tools
:maxdepth: 1
:hidden:

daq buildtools <packages/daq-buildtools/README>
daq cmake <packages/daq-cmake/README>
daq-release <packages/daq-release/README>
styleguide <packages/styleguide/README>
```

```{toctree}
:caption: Core
:maxdepth: 1
:hidden:

appfwk <packages/appfwk/README>
cmdlib <packages/cmdlib/README>
ers <packages/ers/README>
logging <packages/logging/README>
opmonlib <packages/opmonlib/README>
```

```{toctree}
:caption: Readout
:maxdepth: 1
:hidden:

dataformats <packages/dataformats/README>
readout <packages/readout/README>
```

```{toctree}
:caption: Editing Documentation
:maxdepth: 1
:hidden:

Making edits <how_to_make_edits>
Package documentation <editing_package_documentation.md>
```

There are four DUNE DAQ software packages which are used to aid
developers in creating packages designed for the DAQ itself:

To learn how to build an existing software package, read the [daq-buildtools documentation](packages/daq-buildtools/README.md)

To learn how to create a new package or modify the build of an existing one, read the [daq-cmake documentation](packages/daq-cmake/README.md)

To learn about the standard development workflow, read the [daq-release documentation](packages/daq-release/README.md), in particular [this page](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/development_workflow_gitflow/)

To learn about the C++ coding guidelines which DUNE DAQ package developers should follow, read [the styleguide](packages/styleguide/README.md)

--------------

For the other packages, please click on one of the links below. To learn how to edit a package's documentation, click [here](editing_package_documentation.md). Packages marked with an asterix don't yet have any official documentation; please see their Issues page to remedy this. 

### Core

[appfwk](packages/appfwk/README.md) _home of_ daq_application _and tools for writing DAQModules_

[cmdlib](packages/cmdlib/README.md) _interfaces for commanded objects_

[ers](packages/ers/README.md) _fork of the ATLAS Error Reporting System_

[logging](packages/logging/README.md) _contains the functions DUNE DAQ packages use to output text_

### Readout

[dataformats](packages/dataformats/README.md) _raw data reinterpretation utilities_

[readout](packages/readout/README.md) _upstream DAQ readout, DAQModules, CCM interface implementations_

### Control

[minidaqapp](packages/minidaqapp/README.md) _application to read out Felix data and store it in HDF5 files on disk_

[nanorc](packages/nanorc/README.md) _Not ANOther Run Control_

[* rcif](packages/rcif/README.md) _run control related_

[restcmd](packages/restcmd/README.md) _HTTP REST backend based CommandFacility_

### Dataflow (logical)

[dfmessages](packages/dfmessages/README.md) _dataflow messages_

[dfmodules](packages/dfmodules/README.md) _dataflow applications_

[trigemu](packages/trigemu/README.md) _trigger decision emulator for readout application tests_

### Dataflow (physical)

[ipm](packages/ipm/README.md) _message passing between processes_

[nwqueueadapters](packages/nwqueueadapters/README.md) _DAQModules that connect appfwk queues to IPM network connections_

[serialization](packages/serialization/README.md) _utilities for C++ object serialization/deserialization_

### Monitoring

[opmonlib](packages/opmonlib/README.md) _operational monitoring library_

### Educational

[listrev](packages/listrev/README.md) _educational example of DAQModules for new developers_

## Indices and tables

* {ref}`genindex`
* {ref}`modindex`
* {ref}`search`

------

_Mar-11-2021: For software coordinators only:_ [how to make edits to this webpage](how_to_make_edits.md)



