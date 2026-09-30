# Generating Configurations for NP02

To generate the configurations of the AMCs, one can use `tdemodules_gen.py` to create the detector connections, segment and session for the tde readout.

## Generating configurations
Run to generate the tde-testcrate configuration (default):

```[bash]
tdemodules_gen.py
```

Run to genetate the full np02 tde configuration:

```[bash]
tdemodules_gen.py -f tde
```

Note that the starting source ID (source ID of the first CRP) can be changed (defaults to 8)

```[bash]
tdemodules_gen.py -s <some-integer>
```

The host for the dpdk receiver can also be changed (this will also be the host used for the readout application)

```[bash]
tdemodules_gen.py -d <np0x-server-name>
```

The host for communicating with the AMCs can also be changed

```[bash]
tdemodules_gen.py -C <np0x-server-name>
```

and the det_id can be changed if needed

```[bash]
tdemodules_gen.py -D <det-id>
```

## What to do after
Once a configuration is generated, you will see a file made:
```
<detector-name>-det-connections.data.xml
```

Which is kept in `ehn1-daqconfigs/hw/`. Update the include paths in the three respective files.

A few objects need to be created:
- DPDKPortConfiguration
- DPDKReceiver
- NetworkDevice
- HostCores (lcores)
- TDEAMCModuleConf
- TDECrateApplication"

Then the DPDKReceiver needs to be added to the DetectorToDAQConnections.

Next, the Network recievers need to be geenerated, whhich requires the ip and MAC addresses for the NICs. These are found by checking the NICs registered on the server in LanDB. The PCIe address can be inferred through lspci and searching for the device name:

```[bash]
lspci -vv -m | grep -Ew "Device:|NUMANode:"'
```

(note it is easier to use `get_pcie_map.py` from `performancetest` to do this)

Then, the isolated cpus need to be assigned as lcores. The isolated cpus can be found by doing:

```[bash]
sudo cat /sys/devices/system/cpu/isolated
```

to check for any errors in the configuration files, you can run

```[bash]
oks_dump --files-only <xml-file>
```

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Your Name_

_Date: Wed Aug 19 18:19:34 2026 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/tdemodules/issues](https://github.com/DUNE-DAQ/tdemodules/issues)_
</font>
