# Trigger Primitive Dump Info

`tp_dump.py` is a plotting script that shows TP diagnostic information, such as: TP channel histogram and channel vs time over threshold. Plots are saved as SVGs, PDFs, and PNGs.

While running, this script prints various loading information. These outputs can be suppressed with `--quiet`.

One can specify which fragments to load from with the `--start-frag` option. This is -10 by default in order to get the last 10 fragments for the given file. One can also specify which fragment to end on (not inclusive) with `--end-frag` option. This is 0 by default (for the previously mentioned reason).

A text file named `tp_anomaly_summary.txt` is generated that gives reference statistics for each TP data member and gives a count of data members that are at least 2 sigma and 3 sigma from the mean. One can use `--no-anomaly` to stop this file generation.

## Example
```bash
python tp_dump.py file.hdf5 # Loads last 10 fragments by default.
python tp_dump.py file.hdf5 --help
python tp_dump.py file.hdf5 --quiet
python tp_dump.py file.hdf5 --start-frag 50 --end-frag 100 # Loads 50 fragments.
python tp_dump.py file.hdf5 --no-anomaly
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: aeoranday_

_Date: Wed Feb 7 08:50:19 2024 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trgtools/issues](https://github.com/DUNE-DAQ/trgtools/issues)_
</font>
