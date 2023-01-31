# SourceID v2

This document describes the format of the `SourceID` struct, version 2. 

# Description of SourceID

Version 2 of `SourceID` consists of two 32-bit words:



0. Version (upper 16 bits) / Subsystem (lower 16 bits)


1. Element ID

# Notes
Since `SourceID` is a direct successor of the old `GeoID` struct, its versioning picks up where `GeoID` left off at version 1. Unlike `GeoID` which was intended to represent a specific region of the detector, `SourceID` is a generalized concept of where a chunk of data used in the DAQ comes from (e.g., it could be produced by a DAQ application rather than a part of the detector). 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Giovanna Lehmann Miotto_

_Date: Thu Jul 28 09:49:05 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqdataformats/issues](https://github.com/DUNE-DAQ/daqdataformats/issues)_
</font>
