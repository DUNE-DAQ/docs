# Processing TP Streams
`process_tpstream.cxx` (and the application `trgtools_process_tpstream`) processes a timeslice HDF5 that contains Trigger Primitives and creates a new HDF5 that also includes Trigger Activities. A primary use of this is to test TA algorithms and their configurations, with output diagnostics available from `ta_dump.py`.

## Example
```
trgtools_process_tpstream -i input_file.hdf5 -o output_file.hdf5 -j ta_config.json -p TriggerActivityMakerExamplePlugin -m VDColdboxChannelMap --quiet

trgtools_process_tpstream -i input_file.hdf5 -o output_file.hdf5
```
In the second case, the defaults will be

* `-p`: `TAMakerHorizontalMuonAlgorithm`

* `-m`: `VDColdboxChannelMap`

* `-j`: `{
        "trigger_on_adc": false,
        "trigger_on_n_channels": false,
        "trigger_on_tot": false,
        "trigger_on_adjacency": true,
        "adjacency_threshold": 100,
        "adj_tolerance": 3,
        "prescale": 1
      }`

### Configuration
The `ta_config.json` current looks like an individual TA configuration as in daqconf.
```
{
	"trigger_on_adc": false,
	"trigger_on_n_channels": false,
	"trigger_on_tot": false,
	"trigger_on_adjacency": true,
	"window_length": 50000,
	"adjacency_threshold": 10,
	"adj_tolerance": 20,
	"adc_threshold": 5000,
	"prescale": 100
}
```
This will be changed so that it appears exactly as in daqconf, and the option `-p ta_plugin_name` will be dropped.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Fri Jun 14 15:08:05 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trgtools/issues](https://github.com/DUNE-DAQ/trgtools/issues)_
</font>
