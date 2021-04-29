# Introduction

This document describes the format of the ComponentRequest struct, version 0 (unversioned).

# Description of ComponentRequest

ComponentRequest version 0 (unversioned) consists of 6 32-bit words:



0. [GeoID version 0 (unversioned)](GeoIDV0.md) APA Number


1. [GeoID version 0 (unversioned)](GeoIDV0.md) Link Number


2. Window Begin (upper 32 bits)


3. Window Begin (lower 32 bits)


4. Window End (upper 32 bits)


5. Window End (lower 32 bits)

# C++ Code for ComponentRequest

```CPP
struct GeoID
{
  uint32_t apa_number{ std::numeric_limits<uint32_t>::max() };
  uint32_t link_number{ std::numeric_limits<uint32_t>::max() };
};
struct ComponentRequest
{
  GeoID component;
  timestamp_t window_begin{ TypeDefaults::s_invalid_timestamp };
  timestamp_t window_end{ TypeDefaults::s_invalid_timestamp };
};
```

# Notes

ComponentRequest does not currently have a version field. If its format changes, it would have to either be rolled into a version update of the products that use it, or have a version number added.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Thu Apr 29 13:30:23 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dataformats/issues](https://github.com/DUNE-DAQ/dataformats/issues)_
</font>
