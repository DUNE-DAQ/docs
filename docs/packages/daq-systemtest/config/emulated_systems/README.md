# Emulated System Configurations


* 11-Oct-2022, KAB and ELF: Notes on the emulated system config files...

These files are intended to serve as examples for systems that use emulated data producers.

Some of them have been verified to work, and some of them are placeholders, for now.

The ones that have been demonstrated to work are the following:

* `emulated_wib2_system.json` with `emulated_wib2_system_HardwareMap.txt`

* `emulated_wib2_system_k8s.json` with `emulated_wib2_system_HardwareMap.txt`

<!--
Here are sample commands for using them

* make any necessary edits to `long_window_readout.json`

* `daqconf_multiru_gen -c ./long_window_readout.json --hardware-map-file ./long_window_readout_HardwareMap.txt lwr_config`

* `wget https://www.dropbox.com/s/9b1xtkjbkfyakij/frames_wib2.bin`  # if needed

* `nanorc lwr_config ${USER}-test boot conf start_run 101 wait 35 stop_run scrap terminate`

* `rm -i /tmp/dunedaq/swtest*.hdf5`
-->


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: eflumerf_

_Date: Wed Oct 12 15:12:55 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-systemtest/issues](https://github.com/DUNE-DAQ/daq-systemtest/issues)_
</font>
