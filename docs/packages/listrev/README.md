# listrev

The listrev package allows to excercise the basic functioning of DAQ applications, through three simple DAQ Modules that operate on lists of numbers.

In order to run it, setup the runtime environment for hte DAQ version you are using.

To generate a valid configuration file you can issue the following command:
`listrev_gen  --ints-per-list 222 --wait-ms 2000 listref_conf`

The `-h` option will show you the available configuration options.

A directory *listrev_conf* will be created in your working directory.

To run issue the following command:
`nanorc listrev_conf`

You can now boot, i.e. launch, the application and send run control commands to the application, as indicated in the prompt.
It will be possible to monitor the output of the application in the log file (created in the working directory) and operational monitoring (either a file in your working directory or grafana, depending on how you configured the system).


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Giovanna Lehmann Miotto_

_Date: Tue Mar 8 10:06:18 2022 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/listrev/issues](https://github.com/DUNE-DAQ/listrev/issues)_
</font>
