# Testing lbrulibs

## Unit tests

To perform unit tests simply use the --unittest build option:

    dbt-build.sh --unittest

## Integration tests

In the integtest folder there is a pytest integration test, which runs nanorc with an  ND-LAr data generator in the background. To run it use:

    pytest -s test_pacman.py --frame-file $PWD/frames.bin

The frames file is empty thus far, but providing it is required for operation of the framework at present. 

Note - this test requires the larpix-control python library.

## Lbrulibs ND-LAr live readout

To use lbrulibs with a live source of pacman data you can use either minidaqapp for fake triggering, or nanorc to also check if the data in the latency buffer is being properly selected.

For minidaqapp use:

    daq_application -n appNameofYourChoice -c <path_to_source>/lbrulibs/python/lbrulibs/fake_NDreadout.json

With run commands: init, conf, start, (here receive data), stop

To record data to a file issue the 'record' command. Note that this will store a data dump from the luminosity buffer should its occupancy rise above 80%. The stored
data are 'raw' and not subject to any trigger selection.

Note - due to the need for a more configurable fake trigger implementation in readout this test will produce numerous warnings for failed trigger
requests. These can be safely ignored.


For nanorc (requires changes from nightly - tested on version from 24th Oct 2021) use:

    python -m minidaqapp.nanorc.mdapp_multiru_gen --host-ru localhost -o . --number-of-data-producers 1 --frontend-type pacman --trigger-window-before-ticks 2500000 --trigger-window-after-ticks 2500000 --trigger-rate-hz 1.0 --enable-raw-recording mdapp_4proc_pacman_1Hz_pt1second_mode3

to generate a config and then:

    nanorc mdapp_4proc_pacman_1Hz_pt1second_mode3

to run it. With run commands: boot, init, conf, start 1, resume, (here receive data), stop, scrap, exit

### Software data source:

In the test folder there is a python ND-LAr data generator, dependent on python packages:
- larpix-control - tested on version 3.6.0
- pyzmq - tested on version 18.1.1

Example use (start in a separate terminal):

    pacman-generator.py --input_file example-pacman-data.h5

The script is able generate messages in a number of different ways. The interval of time between each message being sent, for example,
is a configurable parameter. For more details run:

    pacman-generator.py --help

To test if the generator is working properly a simple python based ZMQ readout script is provided in the scripts folder:

    python-readout.py

This will receive the packets sent out by the generator over ZMQ and print out some useful debug information.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Krzysztof Furman_

_Date: Fri Oct 29 06:31:38 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/lbrulibs/issues](https://github.com/DUNE-DAQ/lbrulibs/issues)_
</font>