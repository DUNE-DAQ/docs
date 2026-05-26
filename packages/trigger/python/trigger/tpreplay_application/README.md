# Trigger Primitive Replay Application

This is the new Trigger Primitive (TP) Replay Application (v5). For the previous version follow [here](https://github.com/DUNE-DAQ/trigger/tree/production/v4/python/trigger/replay_tps). This change is after new TP format changes (v5.3).

## Table of Contents
- [What is Replay](#what-is-replay)
  - [How does it work?](#how-does-it-work)
- [How to Replay?](#how-to-replay)
  - [General Procedure](#general-procedure)
  - [Using this script](#using-this-script)
    - [Command-Line Options for TP Replay Application](#command-line-options-for-tp-replay-application)
    - [Generating custom configuration](#generating-custom-configuration)
    - [Starting a run with the modified configuration](#starting-a-run-with-the-modified-configuration)
- [Implementation](#implementation)
  - [Python script](#python-script)
  - [Appmodel schemas](#appmodel-schemas)
  - [Appmodel source code](#appmodel-source-code)
  - [Set-up](#set-up)
  - [TP Replay Module](#tpreplaymodule)
  - [OKS Sessions](#oks-sessions)
- [Operational Monitoring](#operational-monitoring)
- [Other Notes](#other-notes)
  - [TODO (future)](#todo-future)

## What is Replay
The replay application is an 'emulation tool'. It is meant for developing the trigger, associated infrastructure, integration, and algorithm testing. 

### How does it work?
The application is replacing the readout and instead uses TPs from offline files (HDF5 TPStream). The implementation is 'emulating' the readout closely, meaning the data is replayed per-plane and per-readout unit. TP Handlers are also part of the same application, exactly as in the current readout application. This is then usually connected to the Trigger Application to more closely resemble a (small) dunedaq system. <br>
<i> Currently, PDS TPs are ignored. Once they are fully implemented in DAQ, replay can be easily expanded to include them (see subdetectors in code). </i>

Process:
- accepts TPStream HDF5 files
- uses `TPReplayModule` to assess the data and extract selected TPs 
- creates TP Handlers (the number depends on configuration), with a configured algorithm
- creates required queues, network connections
- spawns individual threads for each plane
- streams TPs (in vectors), each plane using its own thread
- also contains buffers, which respond to readout requests
- the timing is controlled by a global clock
- as a separate standalone application, it can be used in combination with other DAQ applications

## How to Replay
The easiest way is to use this python module. It helps to retrieve relevant OKS configuration data and modify it given user-provided selection. However, replay can also be run on any (valid) OKS configuration generated outside of this script.<br> 

### General procedure
Replay works via a `TPReplayApplication`, a smart DAQ application that can be used inside your OKS session.<br>
To use it, simply add this application to the appropriate segment in your session. There are example sessions available, both local and with ehn1 integration (CERN's opmon and ers). The implementation in these default sessions includes new `tpreplay-segment`, that only contains the `TPReplayApplication`. This is then linked with the usual (example) trigger and dataflow segments. This exact approach is also adopted by this python script. However, one can choose to include the `TPReplayApplication` in already existing segments. <br><br>
Remember, replay is an emulation of readout and it simply outputs TAs. Therefore, for a full stream a trigger application creating TCs and an MLT application are required (these are typically part of the trigger segment already).<br><br>
Finally, configure the `TPReplayModule` that is part of this application. It accepts a list of input HDF5 TPStream files. Additionally, one can choose to filter out planes. This python script will take care of creating and modifying the configuration given both the parameters from the command line and parameters extracted from data files.

### Using this script
One can use this script that will modify the OKS data with parameters obtained from the provided files.<br>

#### Command-Line Options for TP Replay Application
| Option               | Type         | Default Value  | Description  |
|----------------------|--------------|----------------|--------------|
| `--files`            | `str`        | **Required**   | Text file with full paths to HDF5 TPStream file locations. |
| `--filter-planes`    | `list[int]`  | `[]` (empty)   | List of planes to filter out. Accepts combinations of: <br> `0` (U), `1` (V), `2` (X). Example: `0 1` to filter out both induction planes. |
| `--channel-map`      | `str`        | `PD2HDTPCChannelMap` | Specify channel map. For example: `PD2HDTPCChannelMap`, `PD2VDBottomTPCChannelMap`, etc. For the full list, see: [Channel Maps Documentation](https://github.com/DUNE-DAQ/detchannelmaps/blob/develop/docs/channel-maps-table.md). |
| `--n-loops`          | `int`        | -1             | Number of times to loop over the provided data. The default is `-1` and this results in "infinite" replay. For multiple loops, the time of TPs is modified (shifted). |
| `--config`           | `str`        | `config/daqsystemtest/example-configs.data.xml` | Path to the base OKS configuration file with `tpreplay` session. |
| `--path`             | `str`        | `tpreplay-run` | Path for local output for configuration files. This directory will be created by this script and modified configurations stored there. |
| `--mem-limit`        | `int`        | `25`           | Because the HDF5 files are big and need to be loaded into memory to process there is a limit set (in GBs) on the memory the script can use, to preserve the server. |
| `--verbose`          | `bool`       | `False`        | Enable verbose logging. |

Notes:
- *input text file*:
An example input text file:
```
/nfs/rscratch/mrigan/swtest_tp_run032886_0000_tp-stream-writer-apa1_tpw_4_20241128T081856.hdf5
/nfs/rscratch/mrigan/swtest_tp_run032886_0000_tp-stream-writer-apa2_tpw_4_20241128T081856.hdf5
```
<== text file containing full paths to HDF5 TPStream files, newline-separated.
- *plane filtering*: Option to filter planes. Can be left empty. Otherwise accepts values 0-2, and combinations of those. For example to filter out the collection plane: 
```
--filter-planes 2
```
 To ONLY use the collection plane (and filter two induction planes):
```
--filter-planes 0 1
```
- *channel-map*: valid channel map is needed to extract readout units and planes from TP data. Defaults to `PD2HDTPCChannelMap`. Make sure you are using the correct channel map for your data!
- *n-loops*: the application allows to replay the data multiple times by shifting the TP times. If `-1` is used, the replay will continue indefinitely (until the user stops the run).
- *config*: this is a path to OKS (.data.xml) file that containts default `tpreplay` session. Can be left to use the default.
- *path*: this is a path that will be created locally to store the modified configurations. By default set to `tpreplay-run`.
- *mem-limit*: a limit on max allowed memory usage (in GBs) of this script to protect the server. Default is 25 GBs.
- *verbose*: to enable debugging messages.


*The script makes use of `tqdm` package, which needs to be (pip) installed if not available on the system.*

#### Generating custom configuration
The only required argument is the text file containing the names of TPStream files:
```
python -m trigger.tpreplay_application --files files.txt 
```
<== this will use default values (no filtering).

To only use the collection plane:
```
python -m trigger.tpreplay_application --files files.txt --filter-planes 0 1
```

To use the induction planes and files with data from PD2 VD:
```
python -m trigger.tpreplay_application --files files.txt --filter-planes 2 --channel-map PD2VDBottomTPCChannelMap
```

To change the name of local directory that gets created, and verbose logging:
```
python -m trigger.tpreplay_application --files files.txt --path custom_replay --verbose
```

To only replay once, and set a memory limit to 15 GBs:
```
python -m trigger.tpreplay_application --files files.txt --path custom_replay --n-loops 1 --mem-limit 15
```
and so on.

#### Starting a run with the modified configuration
After a modified configuration is created, one can 'run' with this configuration using `drunc`:
```
drunc-unified-shell ssh-standalone tpreplay-run/example-configs.data.xml local-tpreplay-config $USER-replay
```
<== the `tpreplay-run` name needs to be modified if `path` argument was changed from the default value.<br>
Additionally, the python script modified the `TPReplayApplication` but not the 2 example TPReplay sessions. One can therefore pick `local-tpreplay-config` for a local run or `ehn1-tpreplay-config` for a run with grafana monitoring.
<br>
The last argument is the name of a session which can be anything, but should be easy to identify (use `$USER` as part of the name if possible).
<br><br>
For more details on `drunc` please see [operating-a-daq-with-drunc](https://dune-daq-sw.readthedocs.io/en/latest/packages/drunc/Running-drunc/#operating-a-daq-with-drunc) and [setting up development area](https://github.com/DUNE-DAQ/daqconf/wiki/Setting-up-a-fddaq%E2%80%90v5.3.0-development-area). 
<br><br>

*After using the script, one **can** still modify the local configuration if needed.*
<br><br>

## Implementation
### Python script
Few notes on what happens in this script:
- there is a memory limit applied (safety measure if someone provides 'too many' TPStream files)
- required OKS configuration files are copied over
- retrieves the `TPReplay` application configuration
- retrieves `TPReplayModule` configuration
- loads the `channel map`
- parses TPStream files from the provided text file
- runs basic checks on these files
- extracts readout units and active (used) planes from the data in the provided files (using the provided channel map). Additional data checks are executed, plane filtering is applied. 
- currently the app is set-up to work with TPC TPs only until PDS TPs are fully integrated. It is expected that replay will work easily with PDS TPs as well, but it requires the PDS integration with trigger to happen first.
- TPStream files are sorted by start time
- prepare configuration objects for the extracted options (ie number of total planes, required number of source IDs ...). The general approach is to search for an existing template of the specific DAL object and use that as a base. If it does not exist, a new one is created from scratch (from schema).
- the Random Trigger Candidate Maker is set up to have a rate of 0 (no TC generation from RTCM) as to not mix with the replay TX objects. This can be modified in the final configuration if needed. Additionally, one can also change the rate directly from drunc using `change-rate --trigger-rate X` command.
- finally, update the local OKS files, including storing the new objects and updating relations / references.<br>

### Appmodel schemas
`TPReplayApplication` schema:
```xml
 <class name="TPReplayApplication">
  <superclass name="ResourceSetAND"/>
  <superclass name="SmartDaqApplication"/>
  <attribute name="application_name" type="string" init-value="daq_application" is-not-null="yes"/>
  <relationship name="tp_source_ids" class-type="SourceIDConf" low-cc="zero" high-cc="many" is-composite="no" is-exclusive="no" is-dependent="no"/>
  <relationship name="tprm_conf" class-type="TPReplayModuleConf" low-cc="one" high-cc="one" is-composite="no" is-exclusive="no" is-dependent="no"/>
  <relationship name="tp_handler" class-type="DataHandlerConf" low-cc="one" high-cc="one" is-composite="no" is-exclusive="no" is-dependent="no"/>
  <method name="generate_modules" description="Generate daq module dal objects for TPReplayApplication on the fly">
   <method-implementation language="c++" prototype="std::vector&lt;const dunedaq::confmodel::DaqModule*&gt; generate_modules(conffwk::Configuration*, const std::string&amp;, const confmodel::Session*) const override" body=""/>
  </method>
 </class>
```
- it's own application
- inherits from `SmartDaqApplication`
- Configuration options:
  - *TP Source IDs*: there needs to be *one* source ID *for each* module that has a buffer able to respond to data requests. When using this python script, this is done automatically.
  - configuration for `TPReplayModule` (below)
  - configuration for *TP Handler (TA Maker)*
- declaration of `generate_modules` function (modules & connections build instructions)
<br>

`TPReplayModule` schema: 
```xml
 <class name="TPReplayModule">
  <superclass name="DaqModule"/>
  <relationship name="configuration" class-type="TPReplayModuleConf" low-cc="one" high-cc="one" is-composite="no" is-exclusive="no" is-dependent="no"/>
 </class>

 <class name="TPReplayModuleConf">
  <attribute name="template_for" type="class" init-value="TPReplayModule"/>
  <attribute name="number_of_loops" type="u32" init-value="1" is-not-null="yes"/>
  <attribute name="maximum_wait_time_us" type="u32" init-value="1000" is-not-null="yes"/>
  <attribute name="channel_map" type="string" init-value="PD2HDTPCChannelMap" is-not-null="yes"/>
  <attribute name="total_planes" type="u32" init-value="0" is-not-null="yes"/>
  <attribute name="filter_out_plane" type="u32" range="0..2" init-value="0" is-multi-value="yes"/>
  <relationship name="tp_streams" class-type="TPStreamConf" low-cc="one" high-cc="many" is-composite="no" is-exclusive="no" is-dependent="no"/>
</class>
```
- Configuration options:

| Option                   | Description                                                          loops                                                       |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| **number_of_loops**      | Allows replaying the TPs multiple times with shifted timestamps.                                                            |
| **maximum_wait_time_us** | Max buffer time between sending consecutive TP vectors.                                                                     |
| **channel_map**          | Specifies the detector channel map, used to extract Readout Unit (ROU), planes.                                             |
| **total_planes**         | Represents the total number of unique planes. Required by multiple applications when building modules / linking the system. |
| **filter_out_plane**     | Option to filter out (ignore) data from a specific plane (Induction 1 / Induction 2 / Collection).                          |
| **tp_streams**           | List of TPStream HDF5 files to be used as input (multiple files supported).                                                 |
<br>

TPStream configuration:
```xml
 <class name="TPStreamConf">
  <attribute name="filename" type="string" init-value="1" is-not-null="yes"/>
 </class>
 ```
 Simple full path to your HDF5 TPStream files. Many can be used at once:
![conf_files](https://github.com/user-attachments/assets/665f8e12-0cec-4e63-91ac-69c85b8fc008)
<br>
 
### Appmodel source code
The design of the source code is to be modular. This means the user can provide a vector of files without restrictions on ROUs / planes.
The internal linking is dependent on the **total_planes** variable. If one uses this python script, this is set automatically given the provided files.<br><br>

The **total_planes** counter represents the number of active (non-filtered), unique planes for which data was 'observed' in the provided files.<br>
Therefore, in an example scenario where 4 files are provided, covering 4 unique ROUs (for example 4 different APAs), and no planes are configured to be filtered out, the **total_planes** number would be 4 (ROUs) x 3 (planes) = 12.
This means there would be 12 `TPHandlers`, 12 queues from `TPReplayModule`, 12 data request network connections, 12 outcoming TA publishing network connections.
Importantly, there is always just 1 `TPReplayModule`, however, it will make use of 12 threads, each feeding its own `TPHandler` (pretending to be a plane from readout). 
<br>

It should be mentioned that the application is fully integrated with the rest of the system, such as registering the SourceIDs in MLT and in DFO. 
<br>

### Set-up
#### TPReplayApplication
- Example TP Replay application for 1 ROU and 1 active plane:
![replay_app](https://github.com/user-attachments/assets/b24ecb1b-64d0-4594-8c71-84b1799742af)
- Another example using 2 ROUs and 2 active planes:
![replay3 dot](https://github.com/user-attachments/assets/cdb442e5-0361-43f5-9ca6-d6b9edd91600)

One can see the module generation being driven by the unique ROU and active planes. 
Some additional notes:
- There is always 1 `TPReplayModule` module. It has an internal logic that spawns threads.
- The `TPHandlers` make use of the common `TriggerDataHandlerModules`, meaning they also contain latency buffers, have unique SourceIDs, and respond to data requests.
- The `TPHandlers` create TAs and stream these to output network connections. 
<br>

#### Connecting to the DAQ system
![session](https://github.com/user-attachments/assets/a09fc6f0-b65f-4701-a193-078dbdc78bfd)
- the TPReplayApplication is part of the `tpreplay-segment` (the only application there)
- it has an input from `DFApplication`: readout requests
- it publishes TAs to a `TriggerApplication`; this creates TCs and passes onwards to `MLT`
- generally, the flow is similar to having a readout application replaced (or the whole readout-segment with tpreplay-segment)

### TPReplayModule
The `TPReplayModule` module is the base of replay.
Functionality:
- loads in configuration; including HDF5 files, planes, channel map...
- runs checks on files: file exists, is valid HDF5, is TPStream type, has valid fragments, contains TPs
- loops over files, extracts the ROU, extracts the plane, and stores the TP data in a map (map[ROU][plane][TP data in vectors]). This data is also sorted by time. Each TP vector represents one fragment from the HDF5 file.
- additionally, applies filtering on the plane
- creates unique *streams*, each stream representing a unique plane (and its associated data)
- TP data is handled in TP vectors (this is mostly because it was already available for `TriggerDataHandlerModule`, was previously using `TPSets` but there is no implementation for this data type)
- each stream spawns a unique thread, running independently (timing controlled by clock)
- running threads check the slice time (slice, in this case, represented as a vector of TPs, covering one fragment of TPs), compare to the clock, and send over the queues to `TPHandlers` as appropriate. There is an additional wait time applied so as to not overwhelm the system.
- if multiple loops are configured, the TP times are shifted to allow for repetition with new/future times
- publishes opmon data
- has basic logging / counters


Additionally, multiple new issues have been declared to handle errors, for example:
- `ReplayConfigurationProblem`: Missing or incorrect configuration
- `ReplayNoValidFiles`: No provided file passes checks
- `ReplayNoValidTPs`: No valid TPs have been extracted
For full list please see: [Issues.hpp](./../../include/trigger/Issues.hpp)


#### Logging
Verbose logging is available in the `TPReplayModule`:
- Configuration:
```
### REPLAY CONFIGURATION ###
Will use channel map: PD2HDTPCChannelMap
Plane filtering: 1
Planes to filter:
0
```
- File overview:
```
Files to use:
Index: 1, Filename: /nfs/rscratch/mrigan/swtest_tp_run032886_0000_tp-stream-writer-apa3_tpw_4_20241128T081856.hdf5
Index: 2, Filename: /nfs/rscratch/mrigan/swtest_tp_run032886_0000_tp-stream-writer-apa2_tpw_4_20241128T081856.hdf5
```
- File data summary:
```
Data loading summary (end of file):
------------------------------
File: /nfs/rscratch/mrigan/swtest_tp_run032886_0000_tp-stream-writer-apa3_tpw_4_20241128T081856.hdf5
  ROUs: 1
  Planes: 3
  TP vectors: 90
  Total read TPs: 47488238
```
- Overall data loading summary:
```
Data loading summary (all):
------------------------------
Files: 2
  ROU: APA_P01SU, Number of planes: 2
    Plane: 1, Number of vectors: 44
    Plane: 2, Number of vectors: 44
  ROU: APA_P02NL, Number of planes: 2
    Plane: 1, Number of vectors: 45
    Plane: 2, Number of vectors: 45
```
- Thread summary after running:
```
Thread summary:
------------------------------
Sent TPs: 32738550
TP vectors: 44
Time taken: 42285 ms
Rate: 1.04056 TP vectors/s
Failed to push TP vectors: 0
```
- Global (aggregated) summary:
```
### SUMMARY ###
------------------------------
Generated TP vectors: 178
Generated TPs: 94783270
Time taken: 121693 ms
Rate: 1.4627 TP vectors/s
Failed to push TP vectors: 0
```
This can be compared with opmon from `TPHandlerModule` for sanity checking. 

## OKS Sessions
Two example replay sessions are available as part of example-configs in `daqsystemtest` repository. These are identical in terms of setup, with the only difference being opmon and error reporting. 
- *local-tpreplay-config*: local opmon & reporting
- *ehn1-tpreplay-config*: common cern opmon and reporting

- TPReplay session:

![config_session](https://github.com/user-attachments/assets/1184c148-22de-4785-809a-88579f222100)
<br> -- the session makes use of 'custom' `tpreplay-root-segment`.

- tpreplay-root-segment:

![config_root-segment](https://github.com/user-attachments/assets/f5d41461-cf48-45b1-99b0-80bbe98915eb)
<br> -- the root segment contains the `tpreplay-segment` itself (which containst the `TPReplayApplication`), and additionally `trg-segment` (which contains trigger and MLT applications) and `df-segment` (which is needed for data-flow: readout requests). 

- tpreplay-segment:

![config_replay-segment](https://github.com/user-attachments/assets/fa7268de-a5d9-43d9-a874-b72cef3112c8)
<br> -- this segment contains the `TPReplayApplication`. It should be noted that this is the suggested example set-up, but in theory one only needs to include the `TPReplayApplication` (properly configured) in their session (no need for special segments).

- `TPReplayModule` configuration:

![tpmm](https://github.com/user-attachments/assets/fc0ab564-d57e-47b9-b46a-0fc0690e06b4)

For plane filtering, the `filter_out_plane` variable accepts multiple values (but can also be empty).

Otherwise, the sessions are kept minimal. Most applications that are not needed are disabled (but can be used of course). You can see an overview [here](#connecting-to-the-daq-system).

## Operational Monitoring
A graph showing opmon data from `TPReplayModule` is available on Grafana: 
> Grafana -> Trigger Flow -> Plugins -> TP Maker

![new_graf](https://github.com/user-attachments/assets/c3490188-32f1-4693-9e25-cf3d0c5b58d8)

This shows TP data being read in, and TP vector data being created and sent. 
Additionally, the handler modules used are typical in the sense that they already provide the expected opmon data (TP receiving rates, TA making rates...). All other objects also have corresponding monitoring (queues, network connections, buffers...). 

## Other Notes
### Issues / Perks
- *Plane filtering*: The code pretends that for APA1 ("APA_P02SU") the collection plane is induction plane 2, and vice-versa. This is by choice, as for NP04 running plane 2 was used as an effective collection plane for APA1.
- *Configuration management*: Current implementation uses 1 queue description and 1 `TPHandler` configuration, which is then used for all the instances of queues and handler objects (with unique names of course). This means that for a file with 3 active planes, the handler for each plane would be using the same algorithm (same for readout).
- *conf stage*: A lot is happening inside the `TPReplayModule` at the conf stage: parsing configuration, multiple checks on HDF5 files, extracting ROUs, actually extracting TP data, plane filtering... Depending on the number of files this can take a lot of time. If needed, the conf step timeout may need to be extended.
- *Expectations ?*: There are many places in the current dune-daq code where expectations are baked in (but not necessarily documented), for example, an expectation for queues that are at times not obvious (ie `TPRequestHandler` is expected to link to `FragmentAggregatorModule`, but this module is not required outside readout).
- *Memory limits*: Some memory optimization is implemented, however, TPStream files are often very big. Because most processing happens within one module (TPMm), memory usage can be an issue for many files at once. You have been warned.

### TODO (future)
- [ ] should the initial TP times be shifted (as if they were streamed 'now') ?
- [ ] option in python script to pick TA algorithm ?
- [ ] support for multiple concurrent (different) makers
- [ ] different filtering options per ROU ?
- [ ] once PDS is fully integrated, expand the python script to also pick up PDS sources and replicate (there is a list of allowed subdetectors, and it simply needs to be expanded by PDS subdetectors).
- [X] when TP format changes (relative `tp.time_peak`) looping logic needs adjusting

For more details please see [this report](https://docs.dunescience.org/cgi-bin/private/ShowDocument?docid=32918). 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: MRiganSUSX_

_Date: Thu Jun 5 20:46:10 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trigger/issues](https://github.com/DUNE-DAQ/trigger/issues)_
</font>
