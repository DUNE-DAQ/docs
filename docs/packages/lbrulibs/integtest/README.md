# lbrulibs README
"integtests" are intended to be automated integration and/or system tests that make use of the
"pytest" framework to validate the operation of the DAQ system in various scenarios.

Here is a sample command for invoking a test (feel free to keep or drop the options in brackets, as you prefer):

```
pytest -s test_mpd-raw.py [--nanorc-option partition-number 2] [--nanorc-option timeout 300]
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Tue Dec 12 11:38:55 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/lbrulibs/issues](https://github.com/DUNE-DAQ/lbrulibs/issues)_
</font>
