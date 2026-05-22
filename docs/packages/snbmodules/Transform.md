# SNB Transform Demonstrator

The SNB Transform process takes the binary data files (written by the readout and transferred using the [Transfer](https://dune-daq-sw.readthedocs.io/en/latest/packages/snbmodules/Transfer) process) and transforms them into the HDF5 data format used by the Offline. The current SNB Demonstrator uses a "mini-DAQ" system to accomplish this, playing back the binary file through a custom readout source module, using a preconfigured fixed-time trigger to select the full file's data, and writing out via a standard Dataflow application.

## SNB Simple Transform Integration Test and Config

The simple_transform_test.py integration test runs against a single file, and uses the preconfigured fixed-time trigger and other objects defined in [simple-transform-test.data.xml](snbmodules/config/snbmodules/simple-transform-test.data.xml). This file is generated using [generate_simple_transform](snbmodules/scripts/generate_simple_transform), which reads an input binary file and creates the appropriate configuration objects for that file.

The test is set up so that if you overwrite the simple-transform-test.data.xml with a new one, it will use the binary file for the test that was used when generating the configuration objects. This allows easy switching between several different binary files while testing the SNB transform demonstrator.

In other words, to run the simple transform test against an arbitrary binary file:
```
generate_simple_transform test.data.xml /path/to/your/binary/file.bin
cp snbmodules/config/snbmodules/simple-transform-test.data.xml{,.bak}
cp test.data.xml snbmodules/config/snbmodules/simple-transform-test.data.xml
pytest -s snbmodules/integtest/simple_transform_test.py
```

N.B. rawdatautils/scripts/hdf5_wibeth_to_binary.py may be useful for obtaining a binary file for use with the simple_transform_test.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: eflumerf_

_Date: Tue Jan 20 08:35:03 2026 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
