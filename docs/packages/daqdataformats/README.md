# DUNE DAQ Data Formats

- This repository contains raw data bitfields and utilities used to decode them
- This repository also contains classes which are generated within the DAQ and intended to be persisted to disk and read by Offline code.
- Class Diagram: ![From dune_common_data_formats.dia](https://github.com/DUNE-DAQ/daqdataformats/raw/develop/docs/dune_common_data_formats.png)

The following are brief descriptions of the various structs in this package, including links to fuller, field-by-field descriptions:

----------


**Fragment**: the data fragment interface, representing the data response of one part of the detector (TPC link, etc.) to a dataflow `DataRequest` message. Contains a `FragmentHeader` and the data payload.


**FragmentHeader**: data-about-the-data, e.g. source, run number, trigger timestamp, etc.

[FragmentHeader description](FragmentHeaderV4.md)

---------------


**TriggerRecordHeaderData**: An assortment of information about a trigger. Trigger timestamp, trigger type, etc.

[TriggerRecordHeaderData description](TriggerRecordHeaderDataV3.md)


**TriggerRecordHeader**: contains an instance of `TriggerRecordHeaderData` and a set of component requests


**TriggerRecord**: contains an instance of `TriggerRecordHeader` and a set of fragments

---------------

[SourceID description](SourceIDV2.md)

---------------

[ComponentRequest description](ComponentRequestV2.md)

--------------



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Mon Jul 11 15:41:08 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqdataformats/issues](https://github.com/DUNE-DAQ/daqdataformats/issues)_
</font>
