# fdreadoutlibs - Far Detector readout libraries
Collection of Far Detector FrontEnd specific readout specializations. This includes type definitions to be used with the implementations in `readoutlibs` and frontend specific specializations (i.e. frame processors or software hit finding). It is the glue between `readoutlibs` and `readoutmodules` that specifies types and implementations for the use of `readoutlibs` that can then be imported by `fdreadoutmodules` to be initialized in the `DataLinkHandler` module.

## Building and setting up the workarea

How to clone and build DUNE DAQ packages, including `readout`, is covered in [the daq-buildtools instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/). For examples on how to run the standalone readout app, take a look at the `fdreadoutmodules` documentation.

## Frontends and features provided by `fdreadoutlibs`
The following frontends and features are provided by this package:

* *Daphne*: Frame processor and request handler to be used with the SkipList latency buffer.

* *SSP*: Only frame processor

* *WIB*: Frame processor for `WIB`, software and hardware `WIB` TPs. Implementation of avx based software hit finding (software tpg) for `WIB`

* *WIB2*: Frame processor for `WIB2`, implementation of avx based software hit finding (software tpg) for `WIB2`

* *WIBETH*: Frame processor for `WIBETH`, implementation of avx based software hit finding (software tpg) for `WIBETH`


# TPG Applications
Here is a short summary of the applications and scripts available in `fdreadoutlibs`. Refer to the code for further details. 

## Emulator

`wibeth_tpg_algorithms_emulator` is a emulator for validating different TPG algorithms, either in a naive or in AVX implementation. The application allows to emulate the workload when running a TPG algorithm and therefore monitor performance metrics. It requires an input binary frame file (check assets-list for valid input files) and it will execute the desired TPG algorithm for a configurable duration (default value is 120 seconds). The application is single threaded, pinned to core 0. 

To use the tool use the following:
```sh
$ wibeth_tpg_algorithms_emualator --help 
Test TPG algorithms
Usage: wibeth_tpg_algorithms_emulator [OPTIONS]

Options:
  -h,--help                   Print this help message and exit
  -f,--frame-file-path TEXT   Path to the input frame file
  -a,--algorithm TEXT         TPG Algorithm (SimpleThreshold / AbsRS)
  -i,--implementation TEXT    TPG implementation (AVX / NAIVE)
  -d,--duration-test INT      Duration (in seconds) to run the test
  -n,--num-frames-to-read INT Number of frames to read. Default: select all frames.
  -t,--tpg-threshold INT      Value of the TPG threshold
  --save-adc-data             Save ADC data
  --save-trigprim             Save trigger primitive data
```

The command line option `save_adc_data` allows to save the raw ADC values in a txt file after the 14-bit to 16-bit expansion. The command line option `save_trigprim`  allows to save the in a file the Trigger Primitive object information in a txt file. 

Example of usage: 
```sh
$ wibeth_tpg_algorithms_emulator --frame_file_path FRAMES_FILE --algorithm SimpleThreshold --implementation AVX --save_adc_data
$ wibeth_tpg_algorithms_emulator --frame_file_path FRAMES_FILE --algorithm AbsRS --implementation AVX  --save_trigprim 
```

## Utility tools and scripts


* `wibeth_binary_frame_reader`: reads a WIBEth frame file (`.bin` file) and prints all the ADC values on screen. Usage `wibeth_binary_frame_reader <input_file_name>`.  


* `wibeth_binary_frame_modifier` is used to create a custom WIBEth frame file suitable for testing different patterns. The application will produce an output file `wibeth_output.bin`. There are no command line options, please refer to the code for further details (e.g. what ADC value to set, which time frame to use, etc.). 


* `plot_trigprim_output_data.py.py` plots the Trigger Primitive output file obtained through `wibeth_tpg_algorithms_emulator` (when `save_trigprim` flag is enabled) and produces a plot called `output_trigger_primitives.png` . This script requires the use of `matplotlib`. To use the script run the following command: 
```sh
python3 plot_trigprim_output_data.py  -f TP_OUTPUT.TXT
```

#### Setup matplotlib on NP04 machines (e.g. `np04-srv-019`)
To use the `matplotlib` python module run the following command on a console where the DUNE-DAQ software area has not been sourced:
```sh
pip install --prefix=$PREFIX_PATH matplotlib
```

# Validation 

## Pattern Generation App 

There is a separate application in the `apps` directory tailored to WIBEth pattern generation. 
It shares common features with `wibeth_tpg_algorithms_emulator`. 

Before running the pattern generation app, please make sure you have downloaded an existing WIBEth binary file from the asset repository, e.g.,

```sh
> assets-list  --subsystem readout
dd156b4895f1b06a06b6ff38e37bd798 readout         WIBEth          valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/d/d/1/wibeth_output_all_zeros.bin
> cp /cvmfs/dunedaq.opensciencegrid.org/assets/files/d/d/1/wibeth_output_all_zeros.bin . 
```
The `wibeth_output_all_zeros.bin` file contains 32 WIBEth frames with all ADC values set to 0. Each frame corresponds to 64 channels and 64 clock-ticks. It is convenient to consider each word in the frame as 64 bits long. The frame header, among other information, contains the 64b timestamp value in the 2nd header word. The difference between the timestamps of every two consecutive WIBEth frames is 2048 (i.e., 64 clock-ticks per frame * 32 
units per clock-tick = 2048).

Currently the TPs stored in text files contain the following hit parameters, e.g. 
```sh
channel,time_start,time_over_threshold,time_peak,adc_integral,adc_peak,type
0,79554162068719975,256,79554162068720103,4528,506
0,79554162068722023,224,79554162068722151,4021,505
```

Then we can proceed to the pattern generation step. 

```sh 
wibeth_tpg_pattern_generator -h
```

Examples:



1. Generate binary file containing the selected pattern
```sh
wibeth_tpg_pattern_generator -f wibeth_output_all_zeros.bin -n 2 -i 0 -t 499 -o 1 -p patt_golden
```



2. In addition to 1., store the hits (currently in a text file) contained in generated binary file
```sh
wibeth_tpg_pattern_generator -f patt_input.bin -n 2 -i 0 -t 499 -o 1 -p patt_golden --save-trigprim
```

## TPG Algorithm Validation 

There is a Python script in the `scripts` directory to compare hits found by the AVX and NAIVE implementations of the TPG algorithm. 

```sh
python sourcecode/fdreadoutlibs/scripts/compare_avx_vs_naive.py -h
```
Example:

```sh
python sourcecode/fdreadoutlibs/scripts/compare_avx_vs_naive.py . -n test_01
```
 
## Test Patterns
This section describes the available patterns. Currently the following patterns are implemented.



1. Golden - most complicated pattern so far.


2. Pulse - Single pulse on a single channel and single time tick.


3. Edge square - a square pulse on the edge between two WIBEth frames.


4. Edge left - a triangular pulse spanning two frames where the hit peak is in the first (left-side) frame.


5. Edge reight - same as 4. but the hit peak is in the the second (right-side) frame.

### Here is a description of the so-called "golden" pattern. 
 
In every frame, one hit is generated and placed in the selected channel.
In every binary file, the hit start time can be offset by the specified number of clock-ticks. The time tick offset value is attached to the name of the output binary file, e.g. `patt_golden_35_wibeth_output.bin`.    

The hit ADC values and the hit parameters are (before pedestal substraction):
```sh
ADC values               : 500 502 504 505 506 505 504 502 500
ts_0                     : initial timestamp from the first frame of the binary file
ts_hit_offset            : hit start clock-tick, varies from 1 to 63  
hit finder threshold     : 499   (recommended)
hit time-over-threshold  : 8 * 32 = 256 (clock-ticks, counted from 0)
hit peak_time            : ts_0  + (time_offset + 4) * 32  e.g.  79554162068719943 + (1 + 4) * 32
hit peak_adc             : 506
hit sum_adc              : 4528
```

## Notes
- The tools and scripts developed have been used for TPG related activities. They have not been generalized to cover all use-cases. If there is a need or feature request, ask mainteners of the repository.  
- The repository also contains tools for WIB2 frames but they are not kept up to date. Please refer to the code or ask mainteners of the repository for help. 



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Ivana Radoslavova Hristova_

_Date: Tue Nov 28 00:40:04 2023 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/fdreadoutlibs/issues](https://github.com/DUNE-DAQ/fdreadoutlibs/issues)_
</font>
