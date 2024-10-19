# NanoRC Integration Tests

These tests run using vanilla pytest, rather than the test framework in the "integrationtest" repository. This is because the framework is more suited to testing configurations, rather than NanoRC itself.

Before running these tests it is required to run `pip uninstall integrationtest`, as otherwise the pytest command will default to using the test framework.

After this, the tests can be run with:
```bash
pytest -s <name_of_test>
```

The `-s` flag can be useful to see the full output of NanoRC to the terminal.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Pierre Lasorak_

_Date: Fri Sep 29 15:59:49 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/nanorc/issues](https://github.com/DUNE-DAQ/nanorc/issues)_
</font>
