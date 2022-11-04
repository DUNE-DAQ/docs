# fdreadoutlibs - Far Detector readout libraries
Collection of Far Detector FrontEnd specific readout specializations. This includes type definitions to be used with the implementations in `readoutlibs` and frontend specific specializations (i.e. frame processors or software hit finding). It is the glue between `readoutlibs` and `readoutmodules` that specifies types and implementations for the use of `readoutlibs` that can then be imported by `readoutmodules` to be initialized in the `DataLinkHandler` module.

## Building and setting up the workarea

How to clone and build DUNE DAQ packages, including `readout`, is covered in [the daq-buildtools instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/). For examples on how to run the standalone readout app, take a look at the `readoutmodules` documentation.

## Frontends and features provided by `fdreadoutlibs`
The following frontends and features are provided by this package:

* *Daphne*: Frame processor and request handler to be used with the SkipList latency buffer.

* *SSP*: Only frame processor

* *WIB*: Frame processor for `WIB`, software and hardware `WIB` TPs. Implementation of avx based software hit finding (software tpg) for `WIB`

* *WIB2*: Frame processor for `WIB2`, implementation of avx based software hit finding (software tpg) for `WIB2`


# Test Software TPG on WIB2

To test the execution of the DUNE WIB2 software TPG, first download a raw data file, either by running `curl https://cernbox.cern.ch/index.php/s/ocrHxSU8PucxphE/download -o wib2-frames.bin` or clicking on the [CERNBox link](https://cernbox.cern.ch/index.php/s/ocrHxSU8PucxphE/download) and put it into `<work_dir>`                                                                                             

Example of `daqconf` configuration file used for testing:

```
{
"boot" : {
   "opmon_impl": "cern"
},

"readout": {
   "enable_software_tpg": true,
   "clock_speed_hz": 62500000,
   "data_file": "./wib2-frames.bin",
   "readout_sends_tp_fragments": false
},

"trigger": {
  "trigger_rate_hz": 10,
  "tpg_channel_map": "HDColdboxChannelMap",
  "enable_tpset_writing" : true
},

"dataflow" : {},

"dqm" : {}

}
```
NOTE: the swtpg was tested with a single link using a local binary input file (AAA 22-09-2022).



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: adam-abed-abud_

_Date: Wed Oct 12 14:54:05 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/fdreadoutlibs/issues](https://github.com/DUNE-DAQ/fdreadoutlibs/issues)_
</font>
