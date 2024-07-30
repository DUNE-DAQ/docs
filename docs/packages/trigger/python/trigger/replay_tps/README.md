# Trigger Replay Application

The "replay_tps" python application is a tool to 'replay' TPs through a configurable trigger application, emulating a 'normal' trigger flow. <br>
This is achieved by having a custom version of `fddaqconf`, replacing readout with TriggerPrimitiveMaker plugin(s). It accepts TPstream HDF5 file(s). This app only creates the configuration. NanoRC is then used to run the system.

## Configuration
It's run using `python -m replay_tps`. Additional arguments:
- `-s` / `--slowdown-factor`: [defalt=1] Can slow the flow of time by dividing the clock frequency, used by by TriggerPrimitiveMaker [TPM]
- `-l` / `--number-of-loops`: [default='-1'] Number of times to loop over the input files (-1 for infinite) by [TPM]
- `-to` / `--tpset-time-offset`: [default=0] A time offset applied to instances of [TPM]
- `-tw` / `--tpset-time-width`: [default=10000] A width of the window used to pack TPs to TPSets by the [TPM]
- `-wt` / `--maximum-wait-time-us`: [default=1000] A litte time buffer to wait between sending TPSets, used by the [TPM]
- `-f` / `--input-file`: [*required] TPStream HDF5 file to be replayed
- `-map` / `--map-file`: [] DRO map file
- `-n` / `--number-of-links`: [default=1] If DRO map not provided, replay will generate one for this number of links
- `--debug`: [flag] Switch to get a lot of printout and dot files
- `json_dir`: The name of the output directory that will hold the configuration files

## Example commands:
```
python -m trigger.replay_tps -f <tpstream_file.hdf5> -map <dro_map.json> <name_of_output_config_folder>
```
Alternatively, one can ommit providing a DRO map file. In this case a map will be generated internally for the `n` number of links specified. For example to use 4 links:
```
python -m trigger.replay_tps -f <tpstream_file.hdf5> -n 4 <name_of_output_config_folder>
```
Finally, one can choose to also provide a custom trigger configuration (specifying makers), otherwise the defaults are use:
```
python -m trigger.replay_tps -f <tpstream_file.hdf5> -c <config.json> <name_of_output_config_folder>
```

## Notes:
- the same data (same file) is passed through each link (can be offset)
- the tpsets are 'custom' made by the TPM
- no readout = no readout buffers
- several applications are 'missing': timing, hsi, tpsetwritter...
- (automated) integration test using replay for new PRs

## Details:
This application consists of 2 scripts:
- `__main__.py`: the custom version of `fddaqconf_gen`
- `replay_tp_app.py`: the definition of the `replay` application

#### __main__.py
This script generates dunedaq configuration. Also calls the `replay_app` from `replay_tp_app.py` which acts as a standalone dunedaq application. Otherwise mostly follows `fddaqconf_gen` but is a stripped-down version.
Functionality:
- check directories
- prepare debug if configured
- load the provided configuration, if none provided load the default one
- expand the configuration: currently only using boot, detector, daq_common, readout, trigger, dataflow
- validate configuration
- check input HDF5 file
- prepare the DRO map, either check the one provided or generate one given the number of links configured
- create the appropriate applications: dataflow, replay, trigger, dfo (notice that there is no readout app at this point, while it is used to prepare theSystem object, it is then replaced by the replay application)
- prepare boot, connect fragment producers, prepare MLT links
- prepare per-app command data
- write final configuration and metadata

#### replay_tp_app.py
This script defines the dunedaq replay application, `replay_app`. The configuration is passed from `__main__.py`. Parameters: slowdown_factor, number_of_loops, n_streams, time_offset, time_width, wait_time. Functionality:
- sets up variables (such as the clock frequency)
- creates tp streams: the number depends on the links of DRO map; these 'pass' the HDF5 tpstream file data
- creates TriggerPrimitiveMaker module
- modifies the mgraph (setting the connections between the TPM and tp streams)

## Example plots:
### Configuration with 1 link
- replay app: <br>
![plot](./doc/1_replay.png)
- system (no frags): <br>
![plot](./doc/1_system_no_frag_prod_connection.png)
- system: <br>
![plot](./doc/1_system.png)
- trigger: <br>
![plot](./doc/1_trigger.png)

### Configuration with 4 links
- replay app: <br>
![plot](./doc/replay.png)
- system (no frags): <br>
![plot](./doc/system_no_frag_prod_connection.png)
- system: <br>
![plot](./doc/system.png)
- trigger: <br>
![plot](./doc/trigger.png)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Michal Rigan_

_Date: Mon Feb 19 12:31:07 2024 +0000_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trigger/issues](https://github.com/DUNE-DAQ/trigger/issues)_
</font>
