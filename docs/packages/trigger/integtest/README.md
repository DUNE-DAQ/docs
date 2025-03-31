# trigger README
"integtests" are intended to be automated integration and/or system tests that make use of the
"pytest" framework to validate the operation of the DAQ system in various scenarios.

Here is a sample command for invoking a test (feel free to keep or drop the options in brackets, as you prefer):

```
pytest -s change_rate_test.py [--nanorc-option log-level debug]  # this nanorc option is still useful even when using drunc
```

For reference, here are the ideas behind the existing tests:

* `change_rate_test.py` - Tests whether the change-rate command properly changes the rate of the RTCM and not the FakeHSI

* `td_leakage_between_runs_test.py` - [Currently Broken] tests whether TriggerDecision messages received by the DFO have the correct run number in certain special conditions

* `tc_time_outside_window_test.py` - [Currently Broken] tests whether TriggerCandidate fragments with a start time outside the configured readout window get correctly included in the TriggerRecord


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Thu Feb 27 13:15:03 2025 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trigger/issues](https://github.com/DUNE-DAQ/trigger/issues)_
</font>
