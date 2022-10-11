# ConfigurationsForCasualUsers
The intention of this page is to provide a few simple configurations that new or casual users can use in order to test the operation of a small demo system that uses emulators instead of real electronics.

After you have successfully followed the steps described in [Instructions for casual or first-time users](InstructionsForCasualUsers.md), we will focus now on a few variations to the default configuration used in those instructions.

First, a reminder to set up your working software environment and download the fake input data file


1. `cd <work_dir>`


2. `source ./dbt-env.sh`


4. `dbt-workarea-env`


5. `curl -o frames.bin -O https://cernbox.cern.ch/index.php/s/0XzhExSIMQJUsp0/download`

Next we generate some sample system configurations and use _[nanorc](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/)_ to run a demo system with them.

The tools to generate these configurations consist of a single Python script that generates DAQ system configurations with different characteristics based on the configuration file given to the script. This script is `daqconf/scripts/daqconf_multiru_gen`. It uses `daqconf/schema/daqconf/confgen.jsonnet` to define the format for configuration JSON files.
The configuration generation files under the `daqconf/python/daqconf/apps` directory were developed to work with the _nanorc_ package, which itself can be seen as a basic Finite State Machine that sends commands and drives the DAQ system.

Here is an example command line which uses the provided JSON file that has all of the default values populated (so it is equivalent to running without any options at all!). Note for the reader that it scrolls horizontally. The command below assumes you also have a hardware map file available, e.g. [this basic example](https://raw.githubusercontent.com/DUNE-DAQ/daq-systemtest/develop/config/default_system_HardwareMap.txt). Further details on hardware map files can be found at the bottom of this page. 
```
daqconf_multiru_gen --hardware-map-file <your hardware map file> --config daqconf/config/daqconf_full_config.json daq_fake00
```
The created configurations will be called `daq_fake<NN>` and there will be a `daq_fake<NN>` directory created containing the produced configuration to be used with  _nanorc_.
The configurations can be run interactively with `nanorc daq_fake<NN> <partition_name>` from the `<work_dir>`.

In the following sections, we will use "dot" notation to indicate JSON paths, so that `readout.data_file $PWD/frames.bin` is equvalent to `"readout": { "data_file": "$PWD/frames.bin" }`.

1) In order to get the set of configuration options that can be overridden from the command line and their `help` , run :
`daqconf_multiru_gen -h`
Command-line options override any options set in the configuration file, which in turn override any default values.

2) The data `Input` and `Output` system configuration options allow the user to change the input data file location and the output data directory path as needed. To specify an input `frames.bin` file from the current directory, a user would use `readout.data_file $PWD/frames.bin`. This file contains data frames that are replayed by fake cards in the current system, and as mentioned above, this file can be downloaded with "`curl -o frames.bin -O https://cernbox.cern.ch/index.php/s/7qNnuxD8igDOVJT/download`". The output data path option `dataflow.apps[n].output_dirs` can be used to specify the directory where output data files are written. If more than one path is provided in the array, the DataWriter will use those directories in rotation for writting TriggerRecords.

3) The default trigger rate generated is 1 Hz per readout unit (RU). This can be changed with the option `trigger.trigger_rate_hz FLOAT` (default 1.0 Hz). 

4) Use option `readout.data_rate_slowdown_factor INTEGER` to slow down the generated data rate by a factor of INTEGER, this is achieved by slowing down the simulated clock speed for generating data. This option is particularly useful when the user is running the system on a slow computer that can't create data fast enough to match what the real electronics can do.

5) Use options `dataflow.apps[n].host_df TEXT` , `trigger.host_trigger TEXT` , `hsi.host_hsi TEXT`  to specify different hosts for the different applications (processes). The default for any unspecified host options will be `localhost`

6) As described in the _nanorc_ documentation, running _nanorc_ can be done in interactively or in batch mode. For batch mode you can specify a sequence of commands to drive MiniDAQ app, for example run :

 `nanorc daq_fake03 <partition_name> boot conf start_run 103 wait 60 stop_run shutdown`

The `start_run <run_number>` command specifies the run_number value to be used. Any meaningful combination of commands is allowed.  Note that the `start_run` command includes an automatically-generated `enable_triggers` command to start the flow of triggers, and the `stop_run` command includes an automatically-generated `disable_triggers` command to stop the flow of triggers.


7) Examine the contents of the HDf5 file with commands like the following:

   * `h5dump-shared -H -A swtest_run000103_0000_*.hdf5`

   * and

   * `hdf5_dump.py -p both -f swtest_run000103_0000_*.hdf5`
   
   For more on `hdf5_dump.py`, run `hdf5_dump.py -h`.

8) Some examples:

slowdown_conf.json (Applying the data slowdown factor from point 4):
```JSON
{
"readout": {
  "data_rate_slowdown_factor": 10
}
}
```
`daqconf_multiru_gen --config slowdown_conf.json daq_fake01`

multi_df.json (Running two dataflow apps):
```JSON
{
"dataflow":{
"apps": [
{"app_name": "dataflow0", "output_dir": "/data1", "host_df": 127.0.0.1 },
{"app_name": "dataflow1", "output_dir": "/data2", "host_df": 127.0.0.2 }
]
}
}
```
`daqconf_multiru_gen --config multi_df.json daq_fake02`

9) One of the key options is the `--hardware-map-file`, or `readout.hardware_map_file`, which points the configuration generators to a `detchannelmaps` hardware map. An example of this file is available [here](https://github.com/DUNE-DAQ/detchannelmaps/blob/develop/test/config/TestHardwareMap.txt). This file defines the links that will be active for this configuration. It can also be generated using [this utility from dfmodules](https://github.com/DUNE-DAQ/dfmodules/blob/develop/python/dfmodules/integtest_file_gen.py)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Tue Oct 4 12:32:38 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
