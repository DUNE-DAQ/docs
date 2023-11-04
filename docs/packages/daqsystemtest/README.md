# daqsystemtest

This repository contains configurations for system-level DAQ tests. Currently, there are two subdirectories:

* `integtest/`: `pytest`-based integration tests

* `config/`: JSON configurations for the `fddaqconf` package's `fddaqconf_gen` (and the `timinglibs` package's `daqconf_timing_gen`)

These tests are meant to be run as part of the release testing procedure to ensure that all of the functionality needed by DUNE-DAQ is present. An example of this would be the [`dunedaq-v3.2.0` release test spreadsheet](https://docs.google.com/spreadsheets/d/1VCIrNpCJmxFIntKK-6MynWt0kQ-v7wrTS46KjMe0_EY) from October 2022. 

For more on the `pytest` integration tests, click [here](integtest/README.md)

For more on horizontal drift coldbox tests (`config/hd_coldbox_tests`), click [here](config/hd_coldbox_tests/README.md)

For more on long window readout tests (`config/long_window_readout`), click [here](config/long_window_readout/README.md)

For more on emulated systems tests (`config/emulated_systems`), click [here](config/emulated_systems/README.md)

# Test-specific notes


* The tests in [`config/timing_systems`](https://github.com/DUNE-DAQ/daqsystemtest/tree/develop/config/timing_systems) consist of a `*_daq.json` file which should be run through `fddaqconf_gen` and a `*_timing.json` file which should be run through `daqconf_timing_gen`

* [`detector_configurations/wib_hd_coldbox.json`](https://raw.githubusercontent.com/DUNE-DAQ/daqsystemtest/develop/config/detector_configurations/wib_hd_coldbox.json) is a configuration for `wibconf_gen`



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Pengfei Ding_

_Date: Wed Oct 11 13:34:51 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqsystemtest/issues](https://github.com/DUNE-DAQ/daqsystemtest/issues)_
</font>
