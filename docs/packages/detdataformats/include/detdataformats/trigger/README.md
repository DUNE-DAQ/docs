# Data selection object definitions and fragment overlay

This directory contains definitions of the objects used in the data
selection system (`TriggerPrimitive`, `TriggerActivity` and
`TriggerCandidate`, collectively `TX`) along with corresponding overlay classes to allow
them to be serialized into fragments.

## Requirements

The design is a little
convoluted in order to respect some requirements:



1. Using the `TX` classes inside data selection should be
   straightforward. In particular, the `inputs` data members of TA and
   TC should be accessible as `std::vector`.


2. Writing `TX` classes into fragments and reading them back should
   not require a third-party library, which might not be available for
   the full life of the experiment (and beyond). This rules out using
   the dunedaq `serialization` package, which uses third-party JSON
   and MsgPack libraries.
   
Requirement 2 naturally leads towards the "overlay" class style used
elsewhere in `detdataformats`. But the existence of a `std::vector`
member means the representation of the classes as used inside DS is
not contiguous in memory, so we need a separate overlay class, along
with conversion functions to go from `TX` to the corresponding overlay
class (and back).

## Design

The TriggerActivity and TriggerCandidate classes consist conceptually
of two parts:



1. The data fields of the class itself (`time_start`, `algorithm`,
   etc)


2. The list of input objects (TriggerPrimitive for TriggerActivity,
   TriggerActivity for TriggerCandidate) that were used to create this
   TA/TC
   
An obvious implementation (and the one used previously in the
`triggeralgs` package) has both items 1 and 2 as fields in the TA/TC
object, eg:

```c++
struct TriggerActivity {
  timestamp_t time_start;
  timestamp_t time_end;
  // More fields...
  std::vector<TriggerPrimitive> inputs;
};

struct TriggerCandidate {
  timestamp_t time_start;
  timestamp_t time_end;
  // More fields...
  std::vector<TriggerActivity> inputs;
};
```

Here, `TriggerCandidate` contains a `std::vector` of `TriggerActivity`,
which in turn contains a `std::vector` of
`TriggerPrimitive`. Converting these nested vectors to a contiguous
set of bytes that's representable as an overlay class is not
straightforward (though probably possible). Instead, we split out the
two conceptual parts of TA/TC like this:

```c++
struct TriggerCandidateData {
  timestamp_t time_start;
  timestamp_t time_end;
  // More fields...
};

struct TriggerCandidate : public TriggerCandidateData {
  // Data fields are inherited from TriggerCandidateData
  std::vector<TriggerActivityData> inputs;
};

// And similarly for TriggerActivity
```

The `inputs` member of `TriggerCandidate` now holds
`TriggerActivityData` instead of `TriggerActivity`. Since
`TriggerActivityData` is a "flat" class with no `std::vector` members,
there are no nested `vector`s to unroll, and a simple overlay class
implementation is possible:

```c++
struct TriggerCandidateOverlay {
  TriggerCandidateData data;
  uint64_t n_inputs; // Number of input objects
  TriggerActivityData inputs[];
};
```

(The last member is a "flexible array member", which is not standard
C++, but is supported by GCC. An alternative would be to remove this
data member and have member functions that get and set
`TriggerActivityData` objects by index, stored contiguously in memory
after the `TriggerCandidateOverlay` object itself. The flexible array
member approach is more in keeping with the "overlay" style, but
either way would work).

The implementation of the overlay type is in the file
`TriggerObjectOverlay.hpp`. The actual implementation uses templates
to allow `TriggerActivityOverlay` and `TriggerCandidateOverlay` to use
common functions.

## Usage

To convert a TA or TC into its corresponding overlay class and write
it into a buffer, first find the required buffer size using
`get_overlay_nbytes()`, passing the `TriggerActivity` or
`TriggerCandidate` as an argument. With a buffer of the correct size,
the overlay class can be written using `write_overlay(object,
buffer)`. To read the overlay object from the buffer, you can either
use `reinterpret_cast<TriggerXOverlay*>(buffer)` or get a TA/TC object
back using `read_overlay()`. Example:

```c++
TriggerCandidate candidate;
// Set fields to some values...

// Find the required buffer size
size_t nbytes = get_overlay_nbytes(candidate);
// Create a buffer of the appropriate size
char* buffer = new char[nbytes];
// Write the `candidate` object as a TriggerCandidateOverlay into `buffer`
write_overlay(candidate, buffer);
// Access via reinterpret_cast:
const TriggerCandidateOverlay& candidate_overlay =

*reinterpret_cast<const TriggerCandidateOverlay*>(buffer);
// Or convert back to TriggerCandidate:
TriggerCandidate candidate_read = read_overlay_from_buffer<TriggerCandidate>(buffer);
delete[] buffer;
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Philip Rodrigues_

_Date: Fri Jan 7 12:03:05 2022 +0000_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/detdataformats/issues](https://github.com/DUNE-DAQ/detdataformats/issues)_
</font>
