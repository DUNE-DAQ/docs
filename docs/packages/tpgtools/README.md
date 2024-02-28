# tpgtools 
Here is a short summary of the applications and scripts available in `tpgtools` 

## Emulator

`wibeth_tpg_algorithms_emulator` is an emulator application for TPG algorithms. It takes as input a Trigger Record file (`*.hdf5` file) and it will execute the selected TPG algorithm on the Trigger Record data. The application is single threaded, pinned to core 0. The core number is configurable.   

To use the tool use the following:
```sh
$ wibeth_tpg_algorithms_emulator --help 
TPG algorithms emulator using input from Trigger Record files
Usage: wibeth_tpg_algorithms_emulator [OPTIONS]

Options:
  -h,--help                   Print this help message and exit
  -f,--file-path-input TEXT   Path to the input file
  -a,--algorithm TEXT         TPG Algorithm (SimpleThreshold / AbsRS)
  -i,--implementation TEXT    TPG implementation (AVX / NAIVE). Default: AVX
  -m,--channel-map TEXT       Select a valid channel map: None, VDColdboxChannelMap, ProtoDUNESP1ChannelMap, PD2HDChannelMap, HDColdboxChannelMap, FiftyLChannelMap
  -n,--num-TR-to-read INT     Number of Trigger Records to read. Default: select all TRs.
  -t,--tpg-threshold INT      Value of the TPG threshold. Default value is 500.
  -c,--core INT               Set core number of the executing TPG thread. Default value is 0.
  --save-adc-data             Save ADC data (first frame only)
  --save-trigprim             Save trigger primitive data
  --parse_trigger_primitive   Parse Trigger Primitive records
```

The command line option `save_adc_data` allows to save the raw ADC values in a txt file after the 14-bit to 16-bit expansion. The command line option `save_trigprim`  allows to save the in a file the Trigger Primitive object information in a txt file. 

Example of usage: 
```sh
$ wibeth_tpg_algorithms_emulator -f swtest_run000035_0000_dataflow0_datawriter_0_20231102T083908.hdf5  -a SimpleThreshold -m PD2HDChannelMap -t 500 --save-trigprim --parse_trigger_primitive
$ wibeth_tpg_algorithms_emulator -f swtest_run000035_0000_dataflow0_datawriter_0_20231102T083908.hdf5  -a AbsRS -m PD2HDChannelMap -t 500 --save-adc-data  -n 5 
```


## Utility tools and scripts


* `wibeth_tpg_workload_emulator` is a simple emulator for TPG algorithm in either a naive or in AVX implementation. The application allows to emulate the workload when running a TPG algorithm and therefore monitor performance metrics. It requires an input binary frame file (check assets-list for valid input files) and it will execute the desired TPG algorithm for a configurable duration (default value is 120 seconds). The application is single threaded, pinned to core 0 (configurable). Check the helper page for more details. Example of usage: `wibeth_tpg_workload_emulator -f wibeth_frame_file.bin` 


* `wibeth_tpg_validation` is a simple emulator for validating different TPG algorithms, either in naive or in AVX implementation. Check the helper page for more details. Usage: `wibeth_tpg_validation -f wibeth_frame_file.bin` 


* `wibeth_binary_frame_reader`: reads a WIBEth frame file (`.bin` file) and prints all the ADC values on screen. Usage `wibeth_binary_frame_reader <input_file_name>`.  


* `wibeth_binary_frame_modifier` is used to create a custom WIBEth frame file suitable for testing different patterns. The application will produce an output file `wibeth_output.bin`. There are no command line options, please refer to the code for further details (e.g. what ADC value to set, which time frame to use, etc.). 


* `streamed_TPs_to_text` tool used to streamed TPs from an HDF5 file (e.g. TPSTream recording) into the text format. Example of usage: 
```sh
streamed_TPs_to_text -i INPUT_TPSTREAM.hdf5  -o OUTPUT.txt
```


* `check_fragment_TPs` tool for reading TP fragments from file and check that they have start times within the request window

## Python utility tools for TP studies

### Python libraries
In the `python` directory, there are some libraries with tools to perform simple analyses on TPs, convert between formats, create images. 
Plotting functions make use of `matplotlib`; to know how to load it in your environment, see the section below.


* `hdf5_converter.py` is a library to read the hdf5 TPstream, using directly the DAQ hdf5 tools.


* `utils.py` is a library with some utility functions, like the one to save TPs into a numpy array (`save_tps_array`).


* `properties_plotter.py` contains some functions to plot the properties of the TPs, like the start time, time over threshold, etc. 
They have several parameters to customize the plots, in particular in some cases the range is handled through the quantile of the distribution. 
Default value is 1, but to get rid of outliers it can be set to 0.9, for example.


* `cluster_maker.py` is a library to cluster TPs basing on channel and/or time. 
Each cluster should then be a track, if the conditions are set to be strict enough (deafult is channel limit 1 and time limit 3 ticks).


* `image_creator.py` contains functions to create images from TPs, that will be 2D histograms (channel vs time). 
Also in this case, many parameters can be set to customize the images, for example to choose if to fix the size or if it will depend on the cluster case by case.


### Python scripts
In the `scripts` directory, there are some example scripts that make useof the python libraries.
To avoid unwanted files in the repo, I added `*.png` to the `.gitignore` file.
Taking these as inspiration, you can create your own scripts to perform the analyses you need.
They have a verbose option (`-v`) that prints out the TPs that are being processed.

#### `plot_tp_properties.py` 

Script to plot all the properties of the TPs: start time, time over threshold, channel, detid, peak, peak time, integral. 
It can accept one or more files are input, both in hdf5 or text format. 
The flag `--superimpose` can be used to plot all the input files on the same plot. 
Default output path is `./`, output files will be named `input_file_timeStart.png` and so on.
You can see all options with 
```sh
python plot_tp_properties.py --help
```

Here an example of usage. `--all` is used to plot all the properties, but you can also choose to plot only one or some of them.
```sh
python plot_tp_properties.py -f INPUT_TPSTREAM.hdf5 INPUT_TPS.txt -n 1000 -e my/output/folder/ --superimpose --all
```


#### `create_images.py` 
Script to create images from TP clusters, ie one or more tracks. 
It accepts one input file (hdf5 or text) and will produce images with increasing numbering in the output directory (default is `./`).
Default detector is "APA", but it can be changed with the flag `--channel-map` to "CRP" or "50L".
The images are by default `png`, named `<view>_track<number>.png`, e. g. `u_track12.png`.
The clusters can be saved to a text file to take a look at them in a readable format, with the flag `--save-clusters`.

You can see full usage with `--help`, here an example:
```sh
python create_images.py -i INPUT_TPSTREAM.hdf5 -n 1000 -o my/output/folder/ --ticks-limit 5 --channel-limit 2 --min-tps 3 
```


#### Setup DAQ environment on lxplus or NP04 machines (e.g. `np04-srv-019`)
To use the tools and scripts in this repository, the DUNE-DAQ software environment must be setup. The following commands are valid for lxplus machines and NP04 machines (e.g. `np04-srv-019`). 
```sh
source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh
setup_dbt latest
dbt-setup-release fddaq-v4.2.0
```
The version of the DUNE-DAQ software can also be a different one than `v4.2.0`.


#### Setup matplotlib on lxplus or NP04 machines (e.g. `np04-srv-019`)
To use the `matplotlib` python module run the following command on a console where the DUNE-DAQ software area has not been sourced:
```sh
export PREFIX_PATH=$HOME
pip install --prefix=$PREFIX_PATH matplotlib
export PYTHONPATH=$HOME/lib/python3.10/site-packages/:$PYTHONPATH
```


## Notes
- The tools and scripts developed have been used for TPG related activities. They have not been generalized to cover all use-cases. If there is a need or feature request, ask mainteners of the repository.  
- The repository also contains tools for WIB2 frames but they are not kept up to date. Please refer to the code or ask mainteners of the repository for help. 



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: evila_

_Date: Wed Feb 7 13:40:30 2024 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/tpgtools/issues](https://github.com/DUNE-DAQ/tpgtools/issues)_
</font>
