# daq-systemtest

This repository contains configurations for system-level DAQ tests. Currently, there are two subdirectories:

* `integtest/`: `pytest`-based integration tests

* `config/`: JSON configurations for [`daqconf_multiru_gen`](https://dune-daq-sw.readthedocs.io/en/latest/packages/daqconf/) (and [`daqconf_timing_gen`](https://dune-daq-sw.readthedocs.io/en/latest/packages/timinglibs/) ). 

These tests are meant to be run as part of the release testing procedure to ensure that all of the functionality needed by DUNE-DAQ is present.

For more on the `pytest` integration tests, click [here](integtest/README.md)

For more on horizontal drift coldbox tests (`config/hd_coldbox_tests`), click [here](config/hd_coldbox_tests/README.md)

For more on long window readout tests (`config/long_window_readout`), click [here](config/long_window_readout/README.md)

For more on emulated systems tests (`config/long_window_readout`), click [here](config/long_window_readout/README.md)

# Test-specific notes


* The tests in [`config/timing_systems`](config/timing_systems) consist of a `*_daq.json` file which should be run through `daqconf_multiru_gen` and a `*_timing.json` file which should be run through `daqconf_timing_gen`

* [`detector_configurations/wib_hd_coldbox.json`](config/detector_configurations/wib_hd_coldbox.json) is a configuration for `wibconf_gen`



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Oct 12 12:05:41 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-systemtest/issues](https://github.com/DUNE-DAQ/daq-systemtest/issues)_
</font>
