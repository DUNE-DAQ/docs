# integrationtest: Helpers for pytest-based DUNE DAQ integration tests

This package provides a simple framework for integration tests of the DUNE DAQ software, using the [pytest](https://docs.pytest.org) testing framework. In this context, an integration test involves generating a set of json files using a python configuration generator, running [nanorc](https://github.com/DUNE-DAQ/nanorc) on those json files, and examining the logs and output files to determine whether the job ran successfully.

# How-to

You must already have a python configuration generator that produces json that can be run with nanorc. Clone this package (`integrationtest`) into `$DBT_AREA_ROOT/sourcecode` as usual, then install with `pip install .` (run in the `integrationtest` directory)

Now you can write your own tests.

Explaining how to write tests is probably easiest with an example. Each test file should be named `test_*.py` or `*_test.py` to follow pytest's [conventions for Python test discovery](https://docs.pytest.org/en/6.2.x/goodpractices.html#test-discovery). Here's `test_integration.py`:

```python
import pytest

import dfmodules.data_file_checks as data_file_checks
import integrationtest.log_file_checks as log_file_checks

# The next three variable declarations *must* be present as globals in the test
# file. They're read by the "fixtures" in conftest.py to determine how
# to run the config generation and nanorc

# The name of the python module for the config generation
confgen_name="minidaqapp.nanorc.mdapp_multiru_gen"
# The arguments to pass to the config generator, excluding the json
# output directory (the test framework handles that)
confgen_arguments=[ "-o", ".", "-s", "10", "-n", "2"]
# The commands to run in nanorc, as a list
nanorc_command_list="boot init conf start 1 resume wait 10 stop scrap terminate".split()

# The tests themselves

def test_nanorc_success(run_nanorc):
    # Check that nanorc completed correctly
    assert run_nanorc.completed_process.returncode==0

def test_log_files(run_nanorc):
    # Check that there are no warnings or errors in the log files
    assert log_file_checks.logs_are_error_free(run_nanorc.log_files)

def test_data_file(run_nanorc):
    # Run some tests on the output data file
    assert len(run_nanorc.data_files)==1

    data_file=data_file_checks.DataFile(run_nanorc.data_files[0])
    assert data_file_checks.sanity_check(data_file)
    assert data_file_checks.check_link_presence(data_file, n_links=1)
    assert data_file_checks.check_fragment_sizes(data_file, min_frag_size=22344, max_frag_size=22344)
```

(Note that you'll need a recent checkout of `dfmodules` for the `import dfmodules.data_file_checks` part).

As you can see, there are two main parts to the file: the "setup" part, consisting of three magic variables that specify how to generate the configuration and run nanorc with it; and the tests themselves, which consist of functions containing `assert`s for conditions that should be true after the nanorc run.

To run the test, go to the directory holding it and:

```bash
pytest -s test_integration.py --frame-file /path/to/frames.bin
```

The test framework handles running python with the confgen specified in the test file, then runs nanorc with the generated json files. Finally, the actual test functions are run.

(The framework searches for the `nanorc` script in `$PATH`. If you want to use a `nanorc` from elsewhere, you can use the `--nanorc-path` argument to point the test to the `nanorc` script).

## Writing test functions

Each test function's name must begin with `test_` and the function should take `run_nanorc` as an argument. The `run_nanorc` argument refers to the return value
of the `run_nanorc` [fixture](https://docs.pytest.org/en/6.2.x/fixture.html#fixtures) from this package. The `run_nanorc` object has attributes:


* `completed_process`: [`subprocess.CompletedProcess`](https://docs.python.org/3/library/subprocess.html#subprocess.CompletedProcess) object with the output of the nanorc process

* `run_dir`:           [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) pointing to the directory in which nanorc was run

* `json_dir`:          [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) pointing to the directory in which the run configuration json files are stored

* `data_files`:        list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the HDF5 data files produced by the run

* `log_files`:         list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the log files produced by the run

* `opmon_files`:       list of [`pathlib.Path`](https://docs.python.org/3/library/pathlib.html#pathlib.Path) with each of the opmon json files produced by the run


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Philip Rodrigues_

_Date: Mon Jul 19 10:15:17 2021 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/integrationtest/issues](https://github.com/DUNE-DAQ/integrationtest/issues)_
</font>
