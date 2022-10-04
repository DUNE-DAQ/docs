# daq-systemtest

This repository contains configurations for system-level DAQ tests. Currently, there are two subdirectories:

* integtest: Pytest-based integration tests

* config: JSON configurations for `daqconf_multiru_gen` (and `daqconf_timing_gen`)

These tests are meant to be run as part of the release testing procedure to ensure that all of the functionality needed by DUNE-DAQ is present.

Version v1.0.1

# Test-specific notes

- The tests in timing_systems consist of a _daq.json file which should be run through `daqconf_multiru_gen` and a _timing.json file which should be run through `daqconf_timing_gen`
- `detector_configurations/wib_hd_coldbox.json` is a configuration for `wibconf_gen`
- For documentation on general integration tests, click [here](integtest/README.md).
- For documentation on the long window readout test, click [here](config/long_window_readout/README.md).



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Tue Oct 4 13:23:58 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-systemtest/issues](https://github.com/DUNE-DAQ/daq-systemtest/issues)_
</font>
