# readout - Readout software and utilities 
Appfwk DAQModules, utilities, and scripts for DUNE Upstream DAQ Readout Software.

## Building

Clone the package into a work area as defined under the instructions of [DUNE-DAQ Appfwk Wiki](https://github.com/DUNE-DAQ/appfwk/wiki/Compiling-and-running).

## Examples
Before running the application, please download a small binary files that contains 120 WIB Frames from the following [CERNBox link](https://cernbox.cern.ch/index.php/s/VAqNtn7bwuQtff3/download). Like:

    curl https://cernbox.cern.ch/index.php/s/VAqNtn7bwuQtff3/download -o /tmp/frames.bin
    
For WIB2 frames, download the following file that contains 120 WIB-2 Frames from the following [CERNBox link](https://cernbox.cern.ch/index.php/s/ocrHxSU8PucxphE). Like:

    curl https://cernbox.cern.ch/index.php/s/ocrHxSU8PucxphE/download -o /tmp/wib2-frames.bin

If you download it to a different destination, please update the path of the source file in the configuration that you will use below. 

After succesfully building the package, from another terminal go to your `workarea` directory and set up the runtime environment:

    dbt_setup_runtime_environment
    
After that, launch a readout emaulation via:

    daq_application -c stdin://sourcecode/readout/test/fakereadout-commands.json
    
Then start typing commands as instructed by the command facility.

## Enabling the fake TP source

The FakeCardReader module is capable of reading raw WIB TP data by enabling the corresponding link 
via configuration. Currently the fake TPs are read out from a binary file (with default location 
at /tmp/tp_frames.bin) and parsed using the "RawWibTp" format.

To get the "tp_frames.bin" TP data:

    curl https://cernbox.cern.ch/index.php/s/686ndOgupTli2RW/download -o /tmp/tp_frames.bin

To test the fake raw WIB TP readout, run

    daq_application -c stdin://sourcecode/readout/test/tpenabled-fakereadout-commands.json


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Roland Sipos_

_Date: Fri Apr 23 10:44:25 2021 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/readout/issues](https://github.com/DUNE-DAQ/readout/issues)_
</font>
