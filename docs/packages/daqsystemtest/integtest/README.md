# daqsystemtest README
### 09-Feb-2026, ELF, KAB, and others: notes on existing integtests

"integtests" are intended to be automated integration and/or system tests that make use of the
"pytest" framework to validate the operation of the DAQ system in various scenarios.

Here is a sample command for invoking a test (feel free to keep or drop the options in brackets, as you prefer):

```
pytest -s minimal_system_quick_test.py [--nanorc-option log-level debug]  # this nanorc option is still useful even when using drunc
```

The "-k" pytest option can be used ro selectively run a subset of the configurations in one of our integtest files.  For example:

```
pytest -s -k TPG 3ru_3df_multirun_test.py
```

The `dunedaq_integtest_bundle.sh` script can be used to run sets of tests from various repositories.  Please see [here](../docs/bundle_script_overview.md) for more information.

For reference, here are the ideas behind the tests that currently exist in this repository:

* `minimal_system_quick_test.py` - verify that a small emulator system works and successfully writes data in a short run

* `readout_type_scan_test.py` - verify that we can write different types of data (WIBEth, DAPHNE, TDE, etc.)

* `3ru_3df_multirun_test.py` - verify that a system with multiple RUs and multiple DF Apps works as expected, including TPG

* `small_footprint_quick_test.py` - like minimal_system_quick_test, but using even fewer computer resources

* `fake_data_producer_test.py` - verify that the FakeDataProdModule DAQModule works as expected

* `long_window_readout_test.py` - verify that readout windows that require TriggerRecords to be split into multiple sequences works as expected

* `3ru_1df_multirun_test.py` - verify that we don't get empty fragments at end run

  * this test is also useful in looking into high-CPU-usage scenarios because it uses 3 data producers in 3 RUs

* `tpstream_writing_test.py` - verify that TPSets are written to the TP-stream file(s)

* `example_system_test.py` - verify that the example configurations in example-configs.data.xml work as expected

* `sample_ehn1_multihost_test.py` - demonstrate the running of DAQ processes on multiple computers at EHN1


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Mon Feb 9 20:54:19 2026 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqsystemtest/issues](https://github.com/DUNE-DAQ/daqsystemtest/issues)_
</font>
