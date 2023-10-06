# Software TPG Tools


`TestTPGAlgorithmsWIBEth` is a testing tool for validating different TPG algorithms, either in a naive or in AVX implementation. To use the tool use the following. Refer to the code for further details.

```sh
$ ./TestTPGAlgorithmsWIBEth --help 
Test TPG algorithms
Usage: ./TestTPGAlgorithms [OPTIONS]

Options:
  -h,--help                   Print this help message and exit
  -f,--frame_file_path TEXT   Path to the input frame file
  -a,--algorithm TEXT         TPG Algorithm (SimpleThreshold / AbsRS)
  -i,--implementation TEXT    TPG implementation (AVX / NAIVE)
  -n,--num_frames INT         Number of frames to read. Default: select all frames.
  -t,--swtpg_threshold INT    Value of the TPG threshold
  --save_adc_data BOOLEAN     Save ADC data (true/false)
  --save_trigprim BOOLEAN     Save trigger primitive data (true/false)
```

The options `save_adc_data` and `save_trigprim` are quite useful. The former allows to save the raw ADC values in a txt file after the 14-bit to 16-bit expansion whereas the latter allows to save the in a file the Trigger Primitive object. 

Example of usage: 
```sh
$ ./TestTPGAlgorithmsWIBEth --frame_file_path FRAMES_FILE --algorithm SimpleThreshold --implementation NAIVE --save_adc_data 1
$ ./TestTPGAlgorithmsWIBEth.cxx --frame_file_path FRAMES_FILE --algorithm SimpleThreshold --implementation AVX  --save_trigprim 1
```

## Tools 
Here is a short summary of other tools available in the software TPG test applications repository. Refer to the code for further details. 

`WIBEthBinaryFrameReader` reads a WIBEth frames bin file and prints the respecting channel and adc values. Usage `./WIB2BinaryFrameReader <input_file_name> <input_channel>`


`WIBEthTestBench` is a test application to check the unpacking step of the SWTPG. 

`WIBEthAddFakeHits` is a utility tool that is used to create a custom WIBEth frame file suitable for testing different patterns. 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: adam-abed-abud_

_Date: Fri Oct 6 09:54:11 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/fdreadoutlibs/issues](https://github.com/DUNE-DAQ/fdreadoutlibs/issues)_
</font>
