# DUNE Detectors Channel Maps

This repository contains the implementations of hardware-offline channel mappings. It defines a plugin called `TPCChannelMap` which consists of two functions:

* `get_offline_channel_from_crate_slot_fiber_chan`: this translates from crate, slot, fiber and FEMB channel numbers into the offline channel number

* `get_plane_from_offline_channel`: this translates from offline channel number into plane number

There are two plugin implementations of `TPCChannelMap`:

* `VDColdboxChannelMap`, for the Vertical Drift Coldbox setup. As of Nov-24-2021 its mapping is initialized via a file called `$DETCHANNELMAPS_SHARE/config/vdcoldbox/vdcbce_chanmap_v2_dcchan3200.txt` (`DETCHANNELMAPS_SHARE` an environment variable)

* `PdspChannelMap`, for ProtoDUNE Single Phase. As of Nov-24-2021 its mapping is initialized by `$DETCHANNELMAPS_SHARE/config/protodunesp1/protoDUNETPCChannelMap_RCE_v4.txt`


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Wed Nov 24 17:38:53 2021 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/detchannelmaps/issues](https://github.com/DUNE-DAQ/detchannelmaps/issues)_
</font>
