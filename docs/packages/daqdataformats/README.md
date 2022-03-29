# DUNE DAQ Data Formats

- This repository contains raw data bitfields and utilities used to decode them
- This repository also contains classes which are generated within the DAQ and intended to be persisted to disk and read by Offline code.
- Class Diagram: ![From dune_common_data_formats.dia](https://github.com/DUNE-DAQ/daqdataformats/raw/develop/docs/dune_common_data_formats.png)

The following are brief descriptions of the various structs in this package, including links to fuller, field-by-field descriptions:

----------


**Fragment**: the data fragment interface, representing the data response of one part of the detector (TPC link, etc.) to a Dataflow DataRequest message. Contains a FragmentHeader and the data payload.


**FragmentHeader**: data-about-the-data, e.g. run number, trigger timestamp, etc.

[FragmentHeader description](FragmentHeaderV3.md)

---------------


**TriggerRecordHeaderData**: An assortment of information about the trigger. Trigger timestamp, trigger type, etc.


**TriggerRecordHeader**: contains an instance of TriggerRecordHeaderData and a set of component requests


**TriggerRecord**: contains an instance of TriggerRecordHeader and a set of fragments

[TriggerRecordHeader description](TriggerRecordHeaderDataV2.md)

[ComponentRequest description](ComponentRequestV1.md)

--------------



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Nov 24 18:01:02 2021 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqdataformats/issues](https://github.com/DUNE-DAQ/daqdataformats/issues)_
</font>
