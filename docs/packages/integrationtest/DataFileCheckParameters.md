# Parameters that should be used to control data-file-check behavior

This package (_integrationtest_) provides infrastructure that we use for developing and running automated integration and regression tests.  Part of what is provided is a set of functions that can be used to validate the DAQ data that is produced in such tests.  Many of these functions are contained in _data_file_checks.py_ (located in the _python/integrationtest_ subdirectory).

The functions that are provided in _data_file_checks.py_ have been written in a way that they can be used for different types of DAQ data (for example, TriggerRecords and TimeSlices, and/or WIBEth data and data fragments produced by the Trigger system).  The way that integtest developers specify the type of data that should be tested, and the success criteria that should be used, is by passing in a Python dictionary that contains a specified set of expected parameters.  

Here is a simple example:
```
wibeth_frag_params = {
    "fragment_type_description": "WIBEth",
    "fragment_type": "WIBEth",
    "expected_fragment_count": (number_of_data_producers * number_of_readout_apps),
    "min_size_bytes": 7272,
    "max_size_bytes": 14472,
    "debug_mask": 0x0,
}
```

Here is a more complicated sample:
```
wibeth_tpset_params = {
    "fragment_type_description": "TP Stream",
    "fragment_type": "Trigger_Primitive",
    "expected_fragment_count": number_of_readout_apps * 3,
    "frag_counts_by_record_ordinal": {"first": {"min_count": 1, "max_count": number_of_readout_apps * 3},
                                      "default": {"min_count": number_of_readout_apps * 3, "max_count": number_of_readout_apps * 3} },
    "min_size_bytes": 72,
    "max_size_bytes": 300000,
    "debug_mask": 0x0,
    "frag_sizes_by_record_ordinal": {  "first": {"min_size_bytes":    128, "max_size_bytes": 275000},
                                      "second": {"min_size_bytes":    128, "max_size_bytes": 275000},
                                        "last": {"min_size_bytes":    128, "max_size_bytes": 275000},
                                     "default": {"min_size_bytes": 190000, "max_size_bytes": 275000} }
}
```

The current set of parameters that are used by multiple data-file-check functions is the following:

- fragment_type - a string that matches one of the available fragment types in daqdataformats/FragmentHeader.hpp.  Users specify which fragment type they want to be tested by specifying this parameter value.
- subdetector - a string that matches one of the available subdetector types in detdataformats/DetID.hpp.  Users can optionally specify the subdetector type for the fragments that they want to be tested with this parameter.  If no value is specified for this parameter, all subdetector types are tested.
- fragment_type_description - this is a short string that will be used to describe the fragment type in general terms in console output from the data-file-checks.
- debug_mask - a numeric value that tells the data-file-check functions which debug messages to print out, if any.  As is typical, 0x0 indicates no debug messages, and lower-number bits enable the more basic debugging printouts.

The following parameters are used by the check_fragment_count() function:

- expected_fragment_count - a numeric value that simply specifies the expected number of fragments
- frag_counts_by_TC_type - a dictionary that specifies minimum and maximum fragment count values as a function of the TriggerCandiate type of the record in the file (e.g. kTiming, kPrescale, kRandom).  This allows different fragment count limites to be specified for different TC types.  There is support specifying a range to be used if the TC type of a given record doesn't have a match in the other entries in the dictionary (the "default").
- frag_counts_by_record_ordinal - a dictionary that specifies minimum and maximum fragment count values by the ordinal number of the record in the file (e.g. first, second, penultimate, last).  This allows different fragment count limites to be specified for different records in the file.  There is support specifying a range to be used if the ordinal number of a given record doesn't have a match in the other entries in the dictionary (the "default").

One or more of these parameters needs to be specified.  If multiple ones are provided, later ones in the list above "win".  So, for example, the record ordinal values over-ride the other two.

The check_fragment_sizes() function expects analagous parameters, that is

- min_size_bytes and max_size_bytes
- frag_sizes_by_TC_type
- frag_sizes_by_record_ordinal


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Wed Dec 18 09:53:02 2024 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/integrationtest/issues](https://github.com/DUNE-DAQ/integrationtest/issues)_
</font>
