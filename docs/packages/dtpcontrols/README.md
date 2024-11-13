# dtpcontrols

This package contains python tools for control of the DUNE Trigger Primitive firmware.

## Control API

The entry point for control of the firmware is the DTPPodNode, which should be created using a uhal::HwInterface :

```C++
uhal::ConnectionManager cm( conn_file_name , {"ipbusflx-2.0"});
uhal::HwInterface flx = cm.getDevice( device_name );
DTPPodNode dtp_pod_node ( flx.getNode() );
```

The DTPPodNode provides methods to navigate the firmware node structure, such as `get_control_node()` etc.  These methods return firmware nodes of various types, which provide further navigation methods, as well as methods that control/configure the firmware.

However, all high level actions can be instigated via methods on DTPPodNode. The C++ applications in test/apps can be used as examples. 

DTPPodNode is not currently thread safe.

## Python tools

hfButler.py provides control, test and diagnostic functions.  Some examples of usage are given below.

Note that the first argument is the device to control. These examples control TPG firmware in one half FELIX.


* reset and configure TPG FW with the internal wibulator data source
```
hfButler.py flx-0-p2-hf init
hfButler.py flx-0-p2-hf cr-if --on --drop-empty
hfButler.py flx-0-p2-hf flowmaster --src-sel wibtor --sink-sel hits
hfButler.py flx-0-p2-hf link hitfinder -t 20
hfButler.py flx-0-p2-hf link mask enable -c 1-63
hfButler.py flx-0-p2-hf link config --dr-on --dpr-mux passthrough --drop-empty
```


* to configure for external data, replace the relevant line above with
```
hfButler.py flx-0-p2-hf flowmaster --src-sel gbt --sink-sel hits
```


* configure the wibulator data source to send patterns.  Note the last line will cause the wiulator to fire in one-shot mode.
```
hfButler.py flx-0-p2-hf wtor -i 0 config dtp-patterns/FixedHits/A/FixedHits_A_wib_axis_32b.txt
hfButler.py flx-0-p2-hf wtor -i 0 fire -l
```

## C++ tools

The following tools test the C++ code in standalone mode (ie. outside dunedaq).  Only basic functionality is provided so far.


* Reset
```
dtpcontrols_test_reset

Usage:
 dtpcontrols_test_reset [options]

Options:
  -c <filename>   connection file name
  -d <device>     device name
```


* Configuration
```
dtpcontrols_test_config

Usage:
 dtpcontrols_test_config [options]

Options:
  -c <filename>   connection file name
  -d <device>     device name
  -v              verbose mode
  -t <threshold>  TP threshold
  -m <mask>       comma-separated list of channels to mask
```


* Enable/disable
```
dtpcontrols_test_enable

Usage:
 dtpcontrols_test_enable [options]

Options:
  -c <filename>    connection file name
  -d <device>      device name
  -s               disable

```


* Monitor
```
dtpcontrols_test_monitor

Usage:
 dtpcontrols_test_monitor [options]

Options:
  -c <filename>   connection file name
  -d <device>     device name
  -v              verbose mode
  -l <n_links>    number of links
  -p <n_pipes>    number of pipes
  -s <period>     time between reads
```



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Jim B_

_Date: Tue Apr 5 13:03:59 2022 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dtpcontrols/issues](https://github.com/DUNE-DAQ/dtpcontrols/issues)_
</font>
