# Processing TP Streams
`process_tpstream.cxx` (and the application `trgtools_process_tpstream`) processes a timeslice HDF5 that contains TriggerPrimitives and creates a new HDF5 that also includes TriggerActivities and TriggerCandidates. The primary use of this is to test TA algorithms, TC algorithms, and their configurations, with output diagnostics available from `ta_dump.py` and `tc_dump.py`. The application also outputs the time in nanoseconds to create a new TA/TC given a new TP/TA to a CSV file in the format: row as a fragment and new TP/TA as each entry in that row. Many of the entries will have a value 0 because they did not result in creating a new TA/TC and can be ignored.

## Example
```bash
trgtools_process_tpstream -i input_file.hdf5 -o output_file.hdf5 -j algo_config.json -p TriggerActivityMakerExamplePlugin -m VDColdboxChannelMap --quiet

trgtools_process_tpstream -i input_file.hdf5 -o output_file.hdf5 -j algo_config.json
```
In the second case, the default map will be `VDColdboxChannelMap`.

### Configuration
The `algo_config.json` configuration mirrors the format that is used in `daqconf`. An example is shown below.
```
{
	"trigger_activity_config": [
	    {
		"adc_threshold": 10000,
		"adj_tolerance": 4,
		"adjacency_threshold": 6,
		"n_channels_threshold": 8,
		"prescale": 100,
		"print_tp_info": false,
		"trigger_on_adc": false,
		"trigger_on_adjacency": true,
		"trigger_on_n_channels": false,
		"window_length": 10000
	    }
	],
	"trigger_activity_plugin": [
	    "TriggerActivityMakerPrescalePlugin"
	],
	"trigger_candidate_config": [
	    {
		"adc_threshold": 10000,
		"adj_tolerance": 4,
		"adjacency_threshold": 6,
		"n_channels_threshold": 8,
		"prescale": 100,
		"print_tp_info": false,
		"trigger_on_adc": false,
		"trigger_on_adjacency": true,
		"trigger_on_n_channels": false,
		"window_length": 10000
	    }
	],
	"trigger_candidate_plugin": [
	    "TriggerCandidateMakerPrescalePlugin"
	]
}
```
When developing new algorithms, it is sufficient to change the plugin name and insert the new configurable parameters.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: aeoranday_

_Date: Tue Mar 26 11:54:54 2024 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trgtools/issues](https://github.com/DUNE-DAQ/trgtools/issues)_
</font>
