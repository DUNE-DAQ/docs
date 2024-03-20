# trigger README
"integtests" are intended to be automated integration and/or system tests that make use of the
"pytest" framework to validate the operation of the DAQ system in various scenarios.

Here is a sample command for invoking a test (feel free to keep or drop the options in brackets, as you prefer):

```
pytest -s td_leakage_between_runs_test.py [--nanorc-option partition-number 2] [--nanorc-option timeout 300]
```

For reference, here are the ideas behind the existing tests:

* `td_leakage_between_runs_test.py` - tests whether TriggerDecision messages received by the DFO have the correct run number in certain special conditions


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Thu Dec 28 13:23:12 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trigger/issues](https://github.com/DUNE-DAQ/trigger/issues)_
</font>
