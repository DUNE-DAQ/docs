# Scripts to help with the running of integtests

The following scripts are intended to help developers find and run _integtests_ (regression and integration tests) in all repositories:


* `dunedaq_integtest_bundle.sh` - runs sets ("bundles") of integtests. This script supports the running of integtests from repositories that have been cloned into a local software area as well as repositories that are being used from a base release on CVMFS.

* `list_available_integtests.sh`

* `list_repos_with_integtests.sh`

Users may choose to primarily use the `dunedaq_integtest_bundle.sh` script, but the two "`list`" scripts may be occasionally useful, so they are also described here.

All of these scripts support the "`--help`" command-line option to provide information on how they should be run. Here is what is currently shown for each of the three scripts:

### dunedaq_integtest_bundle.sh --help

```
Usage:
dunedaq_integtest_bundle.sh [option(s)]

Options:
    -h, --help : prints out usage information
    -r <the list of repositories for which integtests will be run>
       - this can be the name of a single repo
       - it can be a pipe-delimited string with a list of repos, e.g. 'dfmodules|trigger'
       - it can have the special value of "all" - integtests in all repos will be run
       - it can have the special value of "local" - integtests in locally-cloned repos will be run
    -k, --include <pipe-delimited string to select the tests that will be run ('egrep -i' match to test name)>
    -x, --exclude <pipe-delimited string to specify tests to be excluded ('egrep -i' match to test name)>
    -n <number of times to run each individual test, default=1>
    -N <number of times to run the full set of selected tests, default=1>
    --stop-on-failure : causes the script to stop when one of the integtests reports a failure
    --concise-output : suppresses run control and DAQApp messages in order to focus on test results
    --tmpdir : specifies a root directory to use for test output, e.g. a directory instead of '/tmp'
    --list-only : list the tests that match the requested patterns without running them
```

### list_available_integtests.sh --help

```
Usage: list_available_integtests.sh [optional list of repo names|local|all]
  e.g. list_available_integtests.sh daqsystemtest
  If no repo name is specified, integtests for all repos are listed.
  If a special repo name of "local" is specified, only integtests for repos
      in the local software area are listed.
  If a special repo name of "all" is specified, integtests for all repos are listed.
```

### list_repos_with_integtests.sh --help 

```
Usage: list_repos_with_integtests.sh [optional "local" keyword]
  Lists the software repositories that have integration tests (integtests) in them.
  Searches the base releases, local install dir, and local sourcecode dir,
  unless "local" is passed as an argument. In that case, only the local
  install and sourcecode directories are searched.
```

Here are examples of using each of the scripts:

### dunedaq_integtest_bundle.sh

```
(dbt) [biery@daq]$ dunedaq_integtest_bundle.sh --list-only

Integtests from the _daqsystemtest_ repo will be run...

The following tests will be run:
  daqsystemtest/3ru_1df_multirun_test.py
  daqsystemtest/3ru_3df_multirun_test.py
  daqsystemtest/example_system_test.py
  daqsystemtest/fake_data_producer_test.py
  daqsystemtest/long_window_readout_test.py
  daqsystemtest/minimal_system_quick_test.py
  daqsystemtest/readout_type_scan_test.py
  daqsystemtest/small_footprint_quick_test.py
  daqsystemtest/tpg_state_collection_test.py
  daqsystemtest/tpreplay_test.py
  daqsystemtest/tpstream_writing_test.py
  daqsystemtest/trigger_bitwords_test.py

(dbt) [biery@daq]$ dunedaq_integtest_bundle.sh -r listrev --list-only

The following tests will be run:
  listrev/listrev_test.py

(dbt) [biery@daq]$ dunedaq_integtest_bundle.sh -r local --list-only

Building the list of _local_ integtests...

The following tests will be run:
  daqsystemtest/3ru_1df_multirun_test.py
  daqsystemtest/3ru_3df_multirun_test.py
  daqsystemtest/example_system_test.py
  daqsystemtest/fake_data_producer_test.py
  daqsystemtest/long_window_readout_test.py
  daqsystemtest/minimal_system_quick_test.py
  daqsystemtest/readout_type_scan_test.py
  daqsystemtest/small_footprint_quick_test.py
  daqsystemtest/tpg_state_collection_test.py
  daqsystemtest/tpreplay_test.py
  daqsystemtest/tpstream_writing_test.py
  daqsystemtest/trigger_bitwords_test.py
  dfmodules/disabled_output_test.py
  dfmodules/hdf5_compression_test.py
  dfmodules/insufficient_disk_space_test.py
  dfmodules/large_trigger_record_test.py
  dfmodules/max_file_size_test.py
  dfmodules/multiple_data_writers_test.py
  dfmodules/offline_prod_run_test.py
  dfmodules/trmonrequestor_test.py

(dbt) [biery@daq]$ dunedaq_integtest_bundle.sh -r "asiolibs|crtmodules" --list-only

The following tests will be run:
  asiolibs/socket_reader_test.py
  crtmodules/crt_reader_test.py

(dbt) [biery@daq]$ dunedaq_integtest_bundle.sh -r local -k tp --list-only

Building the list of _local_ integtests...

The following tests will be run:
  daqsystemtest/small_footprint_quick_test.py
  daqsystemtest/tpg_state_collection_test.py
  daqsystemtest/tpreplay_test.py
  daqsystemtest/tpstream_writing_test.py
  dfmodules/disabled_output_test.py

(dbt) [biery@daq]$ dunedaq_integtest_bundle.sh -r local -k tp -x "disabled|tpreplay" --list-only

Building the list of _local_ integtests...

The following tests will be run:
  daqsystemtest/small_footprint_quick_test.py
  daqsystemtest/tpg_state_collection_test.py
  daqsystemtest/tpstream_writing_test.py
```

### list_available_integtests.sh

```
(dbt) [biery@daq]$ list_available_integtests.sh

Looking for integtests in _all_ repos...

asiolibs/socket_reader_test.py
crtmodules/crt_reader_test.py
daqsystemtest/3ru_1df_multirun_test.py
daqsystemtest/3ru_3df_multirun_test.py
daqsystemtest/example_system_test.py
daqsystemtest/fake_data_producer_test.py
daqsystemtest/long_window_readout_test.py
daqsystemtest/minimal_system_quick_test.py
daqsystemtest/readout_type_scan_test.py
daqsystemtest/small_footprint_quick_test.py
daqsystemtest/tpg_state_collection_test.py
daqsystemtest/tpreplay_test.py
daqsystemtest/tpstream_writing_test.py
daqsystemtest/trigger_bitwords_test.py
dfmodules/disabled_output_test.py
dfmodules/hdf5_compression_test.py
dfmodules/insufficient_disk_space_test.py
dfmodules/large_trigger_record_test.py
dfmodules/max_file_size_test.py
dfmodules/multiple_data_writers_test.py
dfmodules/offline_prod_run_test.py
dfmodules/trmonrequestor_test.py
hsilibs/iceberg_real_hsi_test.py
listrev/listrev_test.py
snbmodules/simple_transform_test.py
snbmodules/snb_1node_1app_rclone_http_system_quick_test.py
snbmodules/snb_1node_1app_torrent_system_quick_test.py
snbmodules/snb_1node_multiclientapps_rclone_http_system_quick_test.py
snbmodules/snb_minimal_system_test.py
trigger/change_rate_test.py
trigger/tc_time_outside_window_test.py
trigger/td_leakage_between_runs_test.py

(dbt) [biery@daq]$ list_available_integtests.sh local

Looking for integtests in _local_ repos...

daqsystemtest/3ru_1df_multirun_test.py
daqsystemtest/3ru_3df_multirun_test.py
daqsystemtest/example_system_test.py
daqsystemtest/fake_data_producer_test.py
daqsystemtest/long_window_readout_test.py
daqsystemtest/minimal_system_quick_test.py
daqsystemtest/readout_type_scan_test.py
daqsystemtest/small_footprint_quick_test.py
daqsystemtest/tpg_state_collection_test.py
daqsystemtest/tpreplay_test.py
daqsystemtest/tpstream_writing_test.py
daqsystemtest/trigger_bitwords_test.py
dfmodules/disabled_output_test.py
dfmodules/hdf5_compression_test.py
dfmodules/insufficient_disk_space_test.py
dfmodules/large_trigger_record_test.py
dfmodules/max_file_size_test.py
dfmodules/multiple_data_writers_test.py
dfmodules/offline_prod_run_test.py
dfmodules/trmonrequestor_test.py

(dbt) [biery@daq]$ list_available_integtests.sh asiolibs crtmodules

Looking for integtests in the _asiolibs crtmodules_ repo(s)...

asiolibs/socket_reader_test.py
crtmodules/crt_reader_test.py

(dbt) [biery@daq]$ list_available_integtests.sh asdf jklp

Looking for integtests in the _asdf jklp_ repo(s)...

-> "asdf" does not appear to be a valid repository name.
-> "jklp" does not appear to be a valid repository name.
```

### list_repos_with_integtests.sh

```
(dbt) [biery@daq]$ list_repos_with_integtests.sh 

Looking for _all_ repositories with integtests in them...

asiolibs
crtmodules
daqsystemtest
dfmodules
hsilibs
listrev
snbmodules
trigger

(dbt) [biery@daq]$ list_repos_with_integtests.sh local

Looking for _local_ repositories with integtests in them...

daqsystemtest
dfmodules

(dbt) [biery@daq]$ list_repos_with_integtests.sh asdf

Looking for _all_ repositories with integtests in them...

asiolibs
crtmodules
daqsystemtest
dfmodules
hsilibs
listrev
snbmodules
trigger
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Wed Jan 28 09:33:03 2026 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqsystemtest/issues](https://github.com/DUNE-DAQ/daqsystemtest/issues)_
</font>
