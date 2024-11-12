# DUNE Detectors Channel Maps

This repository contains the implementations of hardware-offline channel mappings. It defines a plugin called `TPCChannelMap` which consists of two functions:

* `get_offline_channel_from_crate_slot_fiber_chan`: this translates from crate, slot, fiber and FEMB channel numbers into the offline channel number

* `get_plane_from_offline_channel`: this translates from offline channel number into plane number

A table of available channel map plugins is listed [here](channel-maps-table.md). One can use
```bash
cat CMakeLists.txt | sed -n "s/.*( \([^ ]*ChannelMap\).*/\1/p"
```
to see the channel maps that are being built (this may be a useful cross-check).

An example of using the channel maps plugin can be seen in [dummy_map_test.cxx](/test/apps/dummy_map_test.cxx).


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Alejandro Oranday_

_Date: Tue Oct 1 10:42:25 2024 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/detchannelmaps/issues](https://github.com/DUNE-DAQ/detchannelmaps/issues)_
</font>
