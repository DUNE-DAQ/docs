# rawdatautils

## WIB2	Utilities

### `wib2decoder.py`

```
Usage: wib2decoder.py [OPTIONS] FILENAME

Options:
  -n, --nrecords INTEGER  How many Trigger Records to process (default: all)
  --nskip INTEGER         How many Trigger Records to skip (default: 0)
  --channel-map TEXT      Channel map to load (default: None)
  --print-headers         Print WIB2Frame headers
  --print-adc-stats       Print ADC Pedestals/RMS
  --check-timestamps      Check WIB2 Frame Timestamps
  --help                  Show this message and exit.
```

For example, for HD coldbox data from v2.11 onward, you can do:
```
wib2decoder.py -n 1 --print-headers --print-adc-stats --check-timestamps --channel-map HDColdboxChannelMap <file_name>
```
to dump content of the headers, do some timestamp checks for the frames coming from the same WIB and across different WIBs, and to do some basic processing of the data.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Wesley Ketchum_

_Date: Fri Sep 16 12:52:40 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/rawdatautils/issues](https://github.com/DUNE-DAQ/rawdatautils/issues)_
</font>
