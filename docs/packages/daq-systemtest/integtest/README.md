# integtest/ README, 21-Sep-2022, ELF and KAB

Here is the command for fetching a file that has WIB data in it (to be used in generating emulated data):


* `curl -o frames.bin -O https://cernbox.cern.ch/index.php/s/0XzhExSIMQJUsp0/download`

Here is a sample command for invoking a test:


* `pytest -s readout_type_scan.py [--frame-file $PWD/frames.bin] [--nanorc-option partition-number 3] [--nanorc-option timeout 300]`

For reference, here are the ideas behind the existing tests:

* `readout_type_scan.py` - verify that we can write different types of data (WIB2, PDS, TPG, etc.)

* `command_order_test.py` - verify that only certain sequences of commands are allowed

Specialty tests:

* `iceberg_real_hsi_test.py` - tests the generation of pulser triggers by the real TLU/HSI electronics at the ICEBERG teststand

  * needs to be run on the the iceberg01 computer at the ICEBERG teststand

  * for now, it needs the global timing partition to be started separately (hints provided in output of the test script)

  * this test does not need `--frame-file $PWD/frames.bin`

  * it is useful to run this test with a couple of partition numbers to verify that it can talk to the global timing partition independent of its own partition number

* `felix_emu_wib2_test.py` - tests the readout of emulated WIB2 data from a real FELIX card

  * requires that the emulated data has already been loaded into the FELIX card (hints provided at the start of the output from the test script)

  * has only been tested at the ICEBERG teststand so far

  * this test does not need `--frame-file $PWD/frames.bin`


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Oct 12 12:05:41 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-systemtest/issues](https://github.com/DUNE-DAQ/daq-systemtest/issues)_
</font>
