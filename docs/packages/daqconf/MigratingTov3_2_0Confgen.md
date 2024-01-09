# Migrating to v3.2.0 _daqconf_ Configuration Generation

## Introduction
v3.2.0 introduced several changes to the configuration generation scripts (e.g. _fddaqconf_gen_), most notably introducing the use of configuration files as a replacement for most of the command-line options. This document will serve as a guide for updating a pre-v3.2.0 confgen command line to a v3.2.0 configuration file.

## Notable Changes in v3.2.0


1. Most of the command-line options have been removed from _fddaqconf_gen_


2. Readout apps are configured through the HardwareMapService from _detchannelmaps_, using a "Hardware Map File"

### Creating a configuration file
A default configuration can be generated via `echo '{}' >daqconf.json;fddaqconf_gen -c daqconf.json`. This is the basic starting point, and any non-default options can be specified, using `fddaqconf_gen -h` as the guide for constructing the JSON file (or use the [schema](https://github.com/DUNE-DAQ/daqconf/blob/develop/schema/daqconf/confgen.jsonnet)). For this release, option names have been kept the same as much as possible, so it should be a fairly direct translation.

Example:

v3.1.0 Command line
```
fddaqconf_gen -e -n 10 -a 62144 -b 200000 -f --tpc-region-name-prefix=gio --host-ru np04-srv-030 --host-df np04-srv-004 -o /data0/test --frontend-type wib2 --clock-speed-hz 62500000 --ers-impl cern --opmon-impl cern felix_wib2_10links
```

Let's first reformat that command line so we can see what options we're dealing with:
```
-e                           # (readout.emulator_mode)
-n 10                        # (Deprecated, now in HWMap file)
-a 62144                     # (trigger.trigger_window_after_ticks)
-b 200000                    # (trigger.trigger_window_before_ticks)
-f                           # (readout.use_felix)
--tpc-region-name-prefix=gio # (Deprecated)
--host-ru np04-srv-030       # (Deprecated, now in HWMap file)
--host-df np04-srv-004       # (dataflow.apps[0].host_df)
-o /data0/test               # (dataflow.apps[0].output_paths)
--frontend-type wib2         # (Deprecated, now in HWMap file)
--clock-speed-hz 62500000    # (readout.clock_speed_hz)
--ers-impl cern              # (boot.ers_impl)
--opmon-impl cern            # (boot.opmon_impl)
```

Now, we can assemble the appropriate confgen config JSON:
```JSON
{
"readout": {
  "emulator_mode": true,
  "use_felix": true,
  "clock_speed_hz": 62500000
},
"trigger": {
  "trigger_window_after_ticks": 62144,
  "trigger_window_before_ticks": 200000
},
"dataflow": {
  "apps": [{
    "app_name": "dataflow0",
    "host_df": "np04-srv-003",
    "output_paths": ["/data0/test"]
  }]
},
"boot": {
  "ers_impl": "cern",
  "opmon_impl": "cern"
}
}
```

### Creating a Hardware Map File

As noted in the command line example above, several of the options have been deprecated in favor of the [HardwareMapService](https://github.com/DUNE-DAQ/detchannelmaps/blob/develop/include/detchannelmaps/HardwareMapService.hpp). The Hardware Map file contains all of the links that should be present in the system, in the form of HWInfo structs, one per line. Lines that start with '#' are ignored. A simple generator of this file format (used for the _dfmodules_ integration tests) can be found [here](https://github.com/DUNE-DAQ/dfmodules/blob/develop/python/dfmodules/integtest_file_gen.py).

For our configuration example, we see that we have one readout app on np04-srv-030, reading 10 links. The corresponding HWMap file will be: 
```
# DRO_SourceID DetLink DetSlot DetCrate DetID DRO_Host DRO_Card DRO_SLR DRO_Link 
0 0 0 1 3 np04-srv-030 0 0 0
1 1 0 1 3 np04-srv-030 0 0 1
2 0 1 1 3 np04-srv-030 0 0 2
3 1 1 1 3 np04-srv-030 0 0 3
4 0 2 1 3 np04-srv-030 0 0 4
5 1 2 1 3 np04-srv-030 0 1 0
6 0 3 1 3 np04-srv-030 0 1 1
7 1 3 1 3 np04-srv-030 0 1 2
8 0 4 1 3 np04-srv-030 0 1 3
9 1 4 1 3 np04-srv-030 0 1 4
```

The first column is the Source ID for a given link. Multiple links may have the same SourceID, depending on the detector configuration. The next four fields specify the physical location of the link in hardware coordinates and the [DetID](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/DetID.hpp). Next comes the FELIX card location, as host/card #, and the final two numbers are the link location within the FELIX (Super Logic Region and Link #). For physical (e.g. FELIX links), there are up to 2 SLRs each supporting up to 5 links. For the HD_TPC detector, "DetCrate" corresponds to "APA".

_fddaqconf_gen_ will create a readout app for each unique host/card pair in the given hardware map file. The hardware map can be passed using the `--hardware-map-file` command-line option or via `readout.hardware_map_file`. Note that detector type HD_TPC can be used for both ProtoWIB and DUNEWIB configurations, they are distinguished using `readout.clock_speed_hz`.

### Bonus Example (Coldbox Config)
Command line version:
```
fddaqconf_gen --host-ru np04-srv-028 --host-df np04-srv-001 --host-dfo np04-srv-001 --host-hsi np04-srv-001 --host-trigger np04-srv-001 --op-env np04_coldbox -o /data1 --opmon-impl cern --ers-impl cern -n 10 -b 260000 -a 2144 --clock-speed-hz 62500000 -f --region-id 0 --frontend-type wib2 --thread-pinning-file /nfs/sw/dunedaq/dunedaq-v3.1.0/configurations/thread_pinning_files/cpupin-np04-srv-028.json --hsi-trigger-type-passthrough --enable-dqm --host-dqm np04-srv-001 --dqm-cmap HDCB --dqm-impl cern np04_coldbox_daq_4ms 
```

Options
```
--host-ru np04-srv-028 
--host-df np04-srv-001 
--host-dfo np04-srv-001  # (dataflow.host_dfo)
--host-hsi np04-srv-001  # (hsi.host_hsi)
--host-trigger np04-srv-001  # (trigger.host_trigger)
--op-env np04_coldbox  # (boot.op_env, or --op-env)
-o /data1 
--opmon-impl cern 
--ers-impl cern 
-n 10 
-b 260000 
-a 2144 
--clock-speed-hz 62500000 
-f 
--region-id 0 # (Deprecated)
--frontend-type wib2 
--thread-pinning-file /nfs/sw/dunedaq/dunedaq-v3.1.0/configurations/thread_pinning_files/cpupin-np04-srv-028.json # (readout.thread_pinning_file)
--hsi-trigger-type-passthrough  # (trigger.hsi_trigger_type_passthrough)
```

Configuration file
```JSON
{
"readout": {
  "use_felix": true,
  "clock_speed_hz": 62500000,
  "thread_pinning_file": "/nfs/sw/dunedaq/dunedaq-v3.1.0/configurations/thread_pinning_files/cpupin-np04-srv-028.json"
},
"trigger": {
  "trigger_window_after_ticks": 2144,
  "trigger_window_before_ticks": 260000,
  "hsi_trigger_type_passthrough": true,
  "host_trigger": "np04-srv-001"
},
"dataflow": {
  "host_dfo": "np04-srv-001",
  "apps": [{
    "app_name": "dataflow0",
    "host_df": "np04-srv-001",
    "output_paths": ["/data1"]
  }]
},
"hsi": {
  "host_hsi": "np04-srv-001"
},
"dqm": {
  "enable_dqm": true,
  "host_dqm": [ "np04-srv-001" ],
  "dqm_cmap": "HDCB",
  "dqm_impl": "cern"
},
"boot": {
  "ers_impl": "cern",
  "opmon_impl": "cern",
  "op_env": "np04_coldbox"
}
}
```

HardwareMap.txt:
```
# DRO_SourceID DetLink DetSlot DetCrate DetID DRO_Host DRO_Card DRO_SLR DRO_Link 
0 0 0 0 3 np04-srv-028 0 0 0
1 1 0 0 3 np04-srv-028 0 0 1
2 0 1 0 3 np04-srv-028 0 0 2
3 1 1 0 3 np04-srv-028 0 0 3
4 0 2 0 3 np04-srv-028 0 0 4
5 1 2 0 3 np04-srv-028 0 1 0
6 0 3 0 3 np04-srv-028 0 1 1
7 1 3 0 3 np04-srv-028 0 1 2
8 0 4 0 3 np04-srv-028 0 1 3
9 1 4 0 3 np04-srv-028 0 1 4
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Alessandro Thea_

_Date: Thu Oct 12 16:27:36 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
