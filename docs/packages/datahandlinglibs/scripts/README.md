# Script explanations

The readout-affinity balancer can change the CPU affinities of already running processes and their threads.
One criteria is, that the thread's pthread handle need to be named. `psutil` is a dependency.

The json configuration file holds the application names. Applications with the same name can be further
specified with command line arguments they were launched with. Parent and thread name based CPU masks
are specified.

One can use the script as:

    readout-affinity.py --pinfile example-cpupin.json



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Pierre Lasorak_

_Date: Tue Apr 12 13:37:12 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/datahandlinglibs/issues](https://github.com/DUNE-DAQ/datahandlinglibs/issues)_
</font>
