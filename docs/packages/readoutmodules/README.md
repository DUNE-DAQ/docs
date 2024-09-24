# readoutmodules - Readout plugin collection
Collection of readout specializations.
## Building and setting up the workarea

How to clone and build DUNE DAQ packages, including `readoutmodules`, is covered in [the daq-buildtools instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/). You should follow these steps to set up your workarea that you can then use to run the following examples.

## Examples
Before running the application, please download a small binary file that contains WIB Frames from the following [CERNBox link](https://cernbox.cern.ch/index.php/s/7qNnuxD8igDOVJT), or from the commandline:

    curl https://cernbox.cern.ch/index.php/s/0XzhExSIMQJUsp0/download -o frames.bin
    
For WIB2 frames, download the following file that contains 120 WIB-2 Frames from the following [CERNBox link](https://cernbox.cern.ch/index.php/s/ocrHxSU8PucxphE), or like so:

    curl https://cernbox.cern.ch/index.php/s/ocrHxSU8PucxphE/download -o wib2-frames.bin

If you download it to a different destination, please update the path of the source file in the configuration that you will use below. 

To run a standalone readout app (instructions for the complete minidaqapp are included in the setup instructions above), you first create a config with:

    python -m readoutmodules.app_confgen -n 2 app.json
    
Here, we use a fake card emulator with two WIB links. More options can be viewed with `-h`. Then, start the application with

    daq_application -c stdin://app.json -n test
    
You can now issue commands by typing them and pressing enter. Issue the commands `init`, `conf` and then `start`. You will see some json output from the operational monitoring every 10 seconds.

## Enabling the Software TPG
To enable the SIMD accelerated software hit finding, one can use raw data recorded from ProtoDUNE-SP to get meaningful hits. A subset of these raw files can be found under:

    /eos/experiment/neutplatform/protodune/rawdata/np04/protodune-sp/raw/2020/detector/test/None/02/00/00/01/
    
For single link tests, a good link file can be:

    /eos/experiment/neutplatform/protodune/rawdata/np04/protodune-sp/raw/2020/detector/test/None/02/00/00/01/felix-2020-06-02-093338.0.0.0.bin

The produced hit rate should be around 100kHz.

## Enabling the fake TP source

The FakeCardReader module is capable of reading raw WIB2 TP data by enabling the corresponding link 
via configuration. In emulator mode, the fake TPs are read out from a binary file (with default location 
at ./tp_frames.bin) and parsed using the "RawTp" format `detdataformats`.

To get the "tp_frames.bin" TP data:

    curl https://cernbox.cern.ch/index.php/s/FqMXxSpM3WjgeCN/download -o tp_frames.bin

_Instructions on how to test the fake raw WIB TP readout will be provided/updated here:

Testing TP standalone configuration script with dunedaq-v3.1.0:



1. Download tp_frames.bin file
```
curl https://cernbox.cern.ch/index.php/s/FqMXxSpM3WjgeCN/download -o tp_frames.bin
```



2. Setup v3.1.0 work area and checkout branch
```
git clone https://github.com/DUNE-DAQ/readoutmodules.git -b hristova/tp_appconfgen_fix
dbt-build -j16
```



3. Check TP standalone configuration script was installed
```
find . -name readoutapp_gen -type f -print
readoutapp_gen -h
```



4. Generate configuration (TP links only, WIB2 format)

4a. WIB2
```
readoutapp_gen -n 0 -t 1 -c 2048 -m VDColdboxChannelMap tpapp.json
```
4b. WIB1 (currently default)
```
readoutapp_gen -n 0 -t 1 tpapp.json
```



5. Run test job with nanorc
```
rm -Rf RunConf_1; nanorc tpapp.json test boot conf start_run 001 wait 10 stop_run scrap terminate
```

The fix in branch https://github.com/DUNE-DAQ/readoutmodules/tree/hristova/tp_appconfgen_fix
allows the WIB2 configuration options to be used.



## Modules provided by readoutmodules
`readoutmodules` provides several `DAQModule`s that are listed here:

* `DataLinkHandler`: Abstraction for one link of the DAQ. It receives input from a frontend as raw data and buffers it in memory. Data can be retrieved through a request/response mechanism (requests are of the type `DataRequest` and the response is a `Fragment`). Additionaly, data can be recorded for a specified amount of time and written to disk through a high performance mechanism. The module can handle different frontends and some support additional features. For example, for WIB, software tpg is available and can be enabled. For more details, consult the `readoutlibs` repo that defines and implements a `ReadoutModel`, which this module wraps.

* `FakeCardReader`: This module emulates a frontend that pushes raw data to a `DataLinkHandler` by reading raw data from a file and repeating it over and over, while updating the timestamps of the data. A slowdown factor can be set to run at a lower speed which makes it possible to run the whole DAQ on less powerful systems.

* `DataRecorderModule`: Receives data from an input queue and writes it to disk. It supports writing with `O_DIRECT`, making it more performant in some scenarios.

* `FragmentConsumer`: Consumes fragments and does some sanity checks of the data (for now just for WIB data) like checking the timestamps of the data against the requested window.

* `ErroredFrameConsumer`: Consumes error frames, this module is used as long as there is no other consumer for this information.

* `TimeSyncConsumer`: Consumes timesync messages (and nothing more). Can be used in the standalone readout app.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Fri Jun 14 15:07:13 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/readoutmodules/issues](https://github.com/DUNE-DAQ/readoutmodules/issues)_
</font>
