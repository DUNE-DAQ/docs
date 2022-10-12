# 04-Oct-2022, KAB: Notes on the long-window-readout systemtest config files...

These files have successfully been used on the iceberg01.fnal.gov computer, but they may need local modifications before they can be used elsewhere.  For example, in the JSON file, the following parameters may need to be changed:


* `output_paths` (in `dataflow::apps`) - this parameter should be set to a disk location that is local to the computer *and* has sufficient free space to handle an extra 10+ GB of data. The reason that it should be local is that otherwise the disk writing might be slow, and you may see problems with inhibitted triggers and timeouts at run stop time.

The existing parameter values in the JSON file specify a trigger every 20 seconds, a readout window of 2 seconds, a TriggerRecord max window of 4 msec, and a dataflow token count of 1 (to avoid overloading the system with multiple triggers in flight).

Here is the command that I used to fetch a file that has WIB data in it (to be used in generating emulated data):


* `wget https://www.dropbox.com/s/9b1xtkjbkfyakij/frames_wib2.bin`

Here are the steps that I used in my tests:


* make any necessary edits to `long_window_readout.json`

* `daqconf_multiru_gen -c ./long_window_readout.json --hardware-map-file ./long_window_readout_HardwareMap.txt lwr_config`

* `wget https://www.dropbox.com/s/9b1xtkjbkfyakij/frames_wib2.bin`  # if needed

* `nanorc lwr_config ${USER}-test boot conf start_run 101 wait 35 stop_run scrap terminate`

* `rm -i /tmp/dunedaq/swtest*.hdf5`

I typically use run durations of [(number of desired triggers)*20 + 15] seconds. The reason for this is that the trigger rate in the JSON file is set to 1 per 20 seconds, the first trigger typically doesn't happen until 20 seconds into the run, and I allow 15 seconds after the trigger for the readout of the data to complete.  With the /tmp/dunedaq output area on iceberg01, I see the storage of the data on disk take about 6 seconds.

The data is split into multiple files based on the max_file_size parameter that is set in the JSON file.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Oct 12 12:05:41 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-systemtest/issues](https://github.com/DUNE-DAQ/daq-systemtest/issues)_
</font>
