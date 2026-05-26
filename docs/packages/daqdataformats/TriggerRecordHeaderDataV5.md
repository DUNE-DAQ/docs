# TriggerRecordHeaderData v5

This document describes the format of the `TriggerRecordHeaderData` struct, version 5. It should **not** be updated, but rather kept as a historic record of the data format for this version.

# TriggerRecordHeaderData Description

A version 5 `TriggerRecordHeaderData` consists of 16 32-bit words:



0. Marker (0x33334444)


1. Version (0x00000005)


2. Trigger Number (upper 32 bits)


3. Trigger Number (lower 32 bits)


4. Trigger timestamp (upper 32 bits)


5. Trigger timestamp (lower 32 bits)


6. Number of Requested Components (upper 32 bits)


7. Number of Requested Components (lower 32 bits)


8. Run number


9. Status bits


10. Trigger type (upper 32 bits)


11. Trigger type (lower 32 bits)


12. Sequence number (upper 16 bits) / Max sequence number (lower 16 bits)


13. Padding


14. [SourceID version 2](SourceIDV2.md) Version (upper 16 bits) / Subsystem (lower 16 bits)


15. [SourceID version 2](SourceIDV2.md) Element ID


# C++ code for TriggerRecordHeaderData

```CPP
using run_number_t = uint32_t; 
using trigger_number_t = uint64_t; 
using timestamp_t = uint64_t;
using trigger_type_t = uint32_t; 
using sequence_number_t = uint16_t;

struct TriggerRecordHeaderData
{
  
  static constexpr uint32_t s_trigger_record_header_marker = 0x33334444;
  static constexpr uint32_t s_trigger_record_header_version = 5;
  static constexpr uint64_t s_invalid_number_components = std::numeric_limits<uint64_t>::max();
  static constexpr uint32_t s_default_status_bits = 0;

  uint32_t trigger_record_header_marker = s_trigger_record_header_marker;
  uint32_t version = s_trigger_record_header_version;
  trigger_number_t trigger_number{ TypeDefaults::s_invalid_trigger_number };
  timestamp_t trigger_timestamp{ TypeDefaults::s_invalid_timestamp };
  uint64_t num_requested_components{ s_invalid_number_components };
  run_number_t run_number{ TypeDefaults::s_invalid_run_number };
  uint32_t status_bits{ s_default_status_bits };
  trigger_type_t trigger_type{ TypeDefaults::s_invalid_trigger_type };
  sequence_number_t sequence_number{ TypeDefaults::s_invalid_sequence_number };
  sequence_number_t max_sequence_number{ TypeDefaults::s_invalid_sequence_number };
  uint32_t unused { 0xFFFFFFFF };
  SourceID element_id;
};
```

# Notes

A `TriggerRecordHeaderData` instance is a flat array consisting of a TriggerRecordHeaderData instance followed immediately by zero or more ComponentRequest instances. For TriggerRecordHeaderData version 1, these are assumed to be [ComponentRequest version 0 (unversioned)](ComponentRequestV0.md).

# Changelog

v5. The error bits field has been renamed to status bits to better reflect its intended use.
v4. The trigger type field has been expanded from 16 bits to 64 bits to accomodate a bitset instead of a value field. This moved several later elements, and resulting in a 32-bit padding word to maintain 64-bit alignment.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Thu Jan 22 08:45:15 2026 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqdataformats/issues](https://github.com/DUNE-DAQ/daqdataformats/issues)_
</font>
