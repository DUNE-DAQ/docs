# TPG Applications
Here is a short summary of the applications available in this directory. Refer to the code for further details. 

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

## Utility tools


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


## Notes
- The tools and scripts developed have been used for TPG related activities. They have not been generalized to cover all use-cases. If there is a need or feature request, ask mainteners of the repository.  
- The repository also contains tools for WIB2 frames but they are not kept up to date. Please refer to the code or ask mainteners of the repository for help. 




-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: adam-abed-abud_

_Date: Fri Oct 27 09:22:25 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/fdreadoutlibs/issues](https://github.com/DUNE-DAQ/fdreadoutlibs/issues)_
</font>
