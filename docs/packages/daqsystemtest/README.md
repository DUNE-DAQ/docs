# daqsystemtest

This repository contains configurations and `pytest` _test modules_ for system-level DAQ tests. Currently, there are a few relevant subdirectories:

* `integtest/`: `pytest`-based integration tests, often used for regression testing

* `scripts/`: scripts that help that help run tests and validate configurations

* `config/`: OKS-based configuration files that demonstrate various features of our configuration system

The `pytest` _test modules_ in the `integtests` subdirectory are meant to be run as part of the release testing procedure to ensure that all of the functionality needed by DUNE-DAQ is present.  

For a short summary of the `pytest` integration tests that are currently available, click [here](../integtest/README.md).

For a description of a script that can be used to run multiple integtests from multiple repositories, please see [this page](bundle_script_overview.md).

To see some of the "OKS Session" objects that are at the top level of our example configurations, please see [this file](https://github.com/DUNE-DAQ/daqsystemtest/blob/develop/config/daqsystemtest/example-configs.data.xml).


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Tue Feb 10 13:27:58 2026 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqsystemtest/issues](https://github.com/DUNE-DAQ/daqsystemtest/issues)_
</font>
