# integrationtest: Helpers for pytest-based DUNE DAQ integration tests

This package provides a simple framework for integration tests of the DUNE DAQ software, using the [pytest](https://docs.pytest.org) testing framework. In this context, an integration test involves generating an OKS object database using a python configuration generator, running [drunc](https://github.com/DUNE-DAQ/drunc) with it, and examining the logs and output files to determine whether the job ran successfully.

# How-to

The primary testing module in `integrationtest` is [integrationtest_drunc.py](https://github.com/DUNE-DAQ/integrationtest/blob/develop/python/integrationtest/integrationtest_drunc.py). It supports either passing a complete configuration or using tools in the `daqconf` repo to generate segment applications in a "standard" DUNE-DAQ topology.

The parameters associated with the use of a complete DUNE-DAQ (OKS) configuration are specified in an instance of the `integtest_params_for_predefined_dunedaq_config` Python data class, and the parameters that specify the details of a generated DUNE-DAQ configuration are communicated in an instance of the `integtest_params_for_generated_dunedaq_config` Python data class. (Both of these data classes inherit from the `integtest_param_base_class` data class.)

Explaining how to write tests is probably easiest with an example. Each test file should be named `test_*.py` or `*_test.py` to follow pytest's [conventions for Python test discovery](https://docs.pytest.org/en/6.2.x/goodpractices.html#test-discovery), and they are usually placed in the `integtest` subdirectory of your repository. Here's `test_integration.py`:

```python
import pytest

import integrationtest.data_file_checks as data_file_checks
import integrationtest.log_file_checks as log_file_checks
import integrationtest.data_classes as data_classes

# Use the integrationtest_drunc plugin
pytest_plugins = "integrationtest.integrationtest_drunc" 

# Create a meta-configuration. The parameters in this data class are used by integrationtest_drunc
# and scripts in the daqconf repo to generate the DUNE-DAQ configuration.
config_obj = data_classes.integtest_params_for_generated_dunedaq_config()

# Load pre-configured objects from this OKS database file
config_obj.object_databases = ["config/daqsystemtest/integrationtest-objects.data.xml"]

# Declare the set of configurations to be tested, as a dictionary of name: integtest_param_base_class() pairs or as a list of integtest_param_base_class() objects
confgen_arguments = [config_obj]

# The commands to run in dunerc, as a list (this is read by integrationtest_drunc)
dunerc_command_list="boot conf start --run-number 1 enable-triggers wait 10 disable-triggers wait 2 drain-dataflow wait 2 stop-trigger-sources stop scrap terminate".split()



# The tests themselves

def test_dunerc_success(run_dunerc):
    # Check that dunerc completed correctly
    assert run_dunerc.completed_process.returncode==0

def test_log_files(run_dunerc):
    # Check that there are no warnings or errors in the log files
    assert log_file_checks.logs_are_error_free(run_dunerc.log_files)

def test_data_file(run_dunerc):
    # Run some tests on the output data file
    assert len(run_dunerc.data_files)==1

    data_file=data_file_checks.DataFile(run_dunerc.data_files[0])
    assert data_file_checks.sanity_check(data_file)
    assert data_file_checks.check_link_presence(data_file, n_links=1)
    assert data_file_checks.check_fragment_sizes(data_file, min_frag_size=22344, max_frag_size=22344)
```

As you can see, there are two main parts to the file: the "setup" part, containing definitions of variables used by the integrationtest plugin to configure the tests; and the tests themselves, which consist of functions containing `assert`s for conditions that should be true after the drunc run.

To run the test, go to the directory holding it and:

```bash
pytest -s test_integration.py
```

The test framework handles running python with the confgen specified in the test file, then runs drunc with the generated OKS database (a copy of the database is always made to prevent accidental changes). Finally, the actual test functions are run.

(The framework searches for the `drunc-unified-shell` script in `$PATH`. If you want to use a different run control implementation from elsewhere, you can use the `--dunerc-path` argument to point the test to the script).

## Writing test functions

Each test function's name must begin with `test_` and the function should take `run_dunerc` as an argument. The `run_dunerc` argument refers to the return value
of the `run_dunerc` [fixture](https://docs.pytest.org/en/6.2.x/fixture.html#fixtures) from this package. The `run_dunerc` object has attributes:


* `completed_process`: [`subprocess.CompletedProcess`](https://docs.python.org/3/library/subprocess.html#subprocess.CompletedProcess) object with the output of the run control process

* `confgen_config`: The integtest_param_base_class object used for this test instance

* `config_session_name`: The name of the OKS `Session` object used as the entry-point for the configuration

* `daq_session_name`: The name given for the running session of the DAQ

* `dunerc_commands`:  The list of commands given to run control for this test (useful when running multiple configs/sessions as described below)

* `run_dir`:           [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) pointing to the directory in which dunerc was run

* `config_dir`:          [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) pointing to the directory in which the run configuration is stored

* `data_files`:        list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the HDF5 data files produced by the run

* `tpset_files`:        list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the HDF5 TP files produced by the run

* `trmon_files`:        list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the HDF5 TR-monitoring files produced by the run

* `log_files`:         list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the log files produced by the run

* `opmon_files`:       list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the opmon json files produced by the run

* `daq_session_overall_time`: the amount of time that the DAQ session was active

* `verbosity_helper`:  utility to help determine whether various console messages should be displayed or not based on the verbosity setting provided by the user

## Running multiple configurations/sessions

You may want to run the same tests on the output of multiple confgens (eg, to check that the system works with a particular option both on and off). To do this, add additional entries to the `confgen_arguments` list (or dictionary) in your test script.  

For example,

```python
confgen_arguments=[ basic_config_obj,  altered_config_obj ]
```
or
```python
confgen_arguments={ "Basic": basic_config_obj,  "Altered": altered_config_obj }
```

This will run the configuration generation twice: once with the `basic_config_obj` and once with `altered_test_obj`. The DAQ will be run for each of the resultant configurations (in this example, two `drunc` sessions would be run).

You can have multiple runs of the DAQ per configuration too: modify `dunerc_command_list` to be a list of lists of commands. The total number of DAQ runs will then be `len(confgen_arguments) * len(dunerc_command_list)`. (It is also possible to have multiple runs within a single instance of the DAQ by having your command list include stop..start transitions.)

`pytest` will automatically generate names for each `(confgen_arguments, dunerc_command_list)` pair. You can provide more meaningful names by providing `confgen_arguments` and/or `dunerc_command_list` as a dictionary. Each key is the human-readable name of the instance, and the corresponding value is the list of arguments or commands. Eg, for two dunerc runs with different lengths, with names "longer" and "shorter":

```python
dunerc_command_list={ "longer": "boot conf start --run-number 1 enable-triggers wait 20 disable-triggers wait 2 drain-dataflow wait 2 stop-trigger-sources stop scrap terminate".split(),
                      "shorter": "boot conf start --run-number 1 enable-triggers wait 10 disable-triggers wait 2 drain-dataflow wait 2 stop-trigger-sources stop scrap terminate".split() }
```

## Configuring your test

The meta-configuration objects are defined in the [data_classes.py](https://github.com/DUNE-DAQ/integrationtest/blob/develop/python/integrationtest/data_classes.py) file.

DUNE-DAQ configurations that are specified in `integtest_params_for_generated_dunedaq_config()` data classes are generated using the following steps:


1. Preconfigured objects are loaded (`config_obj.object_databases = ["config/daqsystemtest/integrationtest-objects.data.xml"]`) This file includes elements of the "standard" configuration present in `daqsystemtest`


1. `daqconf` generate.py methods are called by `integrationtest` to create the Segment apps (e.g. `generate_hwmap`, `generate_readout`, ...). The arguments to these methods come from the drunc_config object


1. User-supplied configuration substitutions are applied to the configuration.

If the user supplies an `integtest_params_for_predefined_dunedaq_config()` data class instead, the second step is skipped, and the provided configuration is copied into the output directory instead.

Configuration substitutions are provided by the user as instances of the `config_substitution` data class:
```python
conf_dict.config_substitutions.append(
    data_classes.attribute_substitution(
        obj_class="RandomTCMakerConf",
        updates={"trigger_rate_hz": 1},
    )
)
```
Substitutions can be applied to a single object in the database or all objects of a given class. If obj_id is specified, it applies only to that one object, if found.

The generated configuration will be in the `/tmp/pytest-of-$USER/pytest-current/config*` directories


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Wed May 27 13:58:44 2026 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/integrationtest/issues](https://github.com/DUNE-DAQ/integrationtest/issues)_
</font>
