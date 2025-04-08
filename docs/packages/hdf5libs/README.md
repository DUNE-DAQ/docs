# hdf5libs README
## Overview

The _hdflibs_ repository contains the classes that are used for interfacing between _dunedaq_ data applications (writers and readers) and the [HighFive](https://github.com/BlueBrain/HighFive) library to read/write HDF5 files. 

There are two main classes in use:
- [`HDF5FileLayout`](#hdf5filelayout) governs the layout of DUNE DAQ raw data files, including configurable parameters for the names of groups and datasets (_e.g._ how many digits to use for numbers in names, what to call the groups for TPC data, its underlying regions, etc.), and it includes member functions that use the layout to allow for construction of group and dataset names.
- [`HDF5RawDataFile`](#hdf5rawdatafile) is the main interface for writing and reading HDF files, containing functions to write data and attributres to the files, and functions for reading back that data and attributes, as well as some utilities for file investigation.

More details on those classes are in the sections below, but some important interface points:

* `HDF5RawDataFile` handles only one file at a time. It opens it on construction, and closes it on deletion. If writing multiple files, one will need multiple `HDF5RawDataFile` objects.

* There is no handling for conditions on if/when data should be written to a file, only where in that file it should be written. It is the responsibility of data writer applications to handle conditions on when to switch to a new file (_e.g._ when reaching maximum file size, or having written a desired number of events). 

The general structure of written files is as follows:
```
<File-Level-Attributes>

GROUP Top-Level-Record
  
  DATASET Record-Header
  
  GROUP System-Type-Group
    GROUP Region-Group
      DATASET Element-Data
```
Note that names of datasets and groups are not as shown, and instead are configurable on writing, and later determined by the attributes "filelayout_params".

There are example programs in `app` -- `HDF5LIBS_TestWriter` and `HDF5LIBS_TestReader` -- that show how to use these classes in simple C++ applications. `HDF5LIBS_TestReader.py` shows how to read files using HDF5RawDataFile from a python interface.

### HDF5FileLayout
This class defines the file layout of _dunedaq_ raw data files. It receives a `hdf5filelayout::FileLayoutParams` object for configuration, which looks like the following in json:
```
  "file_layout_parameters":{
    "trigger_record_name_prefix": "TriggerRecord",
    "digits_for_trigger_number": 6,
    "digits_for_sequence_number": 0,
    "trigger_record_header_dataset_name": "TriggerRecordHeader",

    "path_param_list":[ {"detector_group_type":"TPC",
                         "detector_group_name":"TPC",
                         "region_name_prefix":"APA",
                         "digits_for_region_number":3,
                         "element_name_prefix":"Link",
                         "digits_for_element_number":2},
                        {"detector_group_type":"PDS",
                         "detector_group_name":"PDS",
                         "region_name_prefix":"Region",
                         "digits_for_region_number":3,
                         "element_name_prefix":"Element",
                         "digits_for_element_number":2} ]
  }
```
Under this configuration, the general file structure will look something like this:
```
<File-Level-Attributes>

ATTRIBUTE: "filelayout_params" <std::string>
ATTRIBUTE: "filelayout_version" <uint32_3>

GROUP "TriggerRecord000001"
  
  DATASET "TriggerRecordHeader"
  
  GROUP "TPC"
    GROUP "APA001"
      DATASET "Link00"
      DATASET "Link01"
    GROUP "APA002"
      DATASET "Link00"
      DATASET "Link01"
    ...
    
  GROUP "PDS"
    GROUP "Region001"
      DATASET "Element01"
      DATASET "Element02"
    ...
```

The configuration information for the file layout are written as the attribute "filelayout_params" as JSON-formatted `std::string`. When a file is later opened to be read, the file layout parameters are automatically extracted from the attribute, and used to populate an `HDF5FileLayout` member of the `HDF5RawDataFile`. If no attributes exist, currently a set of defaults are used.

### HDF5RawDataFile

#### Writing
The constructor for creating a new HDF5RawDataFile for writing looks like this:
```
  HDF5RawDataFile(std::string file_name,
                  daqdataformats::run_number_t run_number,
                  size_t file_index,
                  std::string application_name,
                  const hdf5filelayout::FileLayoutParams& fl_params,
                  HDF5SourceIDHandler::source_id_geo_id_map_t srcid_geoid_map,
                  unsigned compression_level = 0,
                  std::string inprogress_filename_suffix = ".writing",
                  unsigned open_flags = HighFive::File::Create);
```
Upon opening the file -- at object construction -- the following attributes are written:
- "run_number" (`daqdataformats::run_number_t`)
- "file_index" (`size_t`)
- "creation_timestamp" (`std::string`, string translation of the number of milliseconds since epoch)
- "application_name" (`std::string)
- "compression_level" (`unsigned`, zlib compression level 0&ndash-9, default: 0)

alongside the file layout paramters as described [above](#hdf5filelayout).

Upon closing the file -- at object destruction -- the following attributes are written:
- "recorded_size" (`size_t`, number of bytes written in datasets)
- "uncompressed_raw_data_size" (`size_t`, uncompressed number of bytes contained in all TriggerRecord or TimeSlice objects)
- "total_file_size" (`size_t`, total number of bytes in the file, including datasets, metadata, and unallocated space)
- "closing_timestamp" (`std::string`, string translation of the number of milliseconds since epoch).

The key interface for writing is the `HDF5RawDataFile::write(const daqdataformats::TriggerRecord& tr)` member, which takes a TriggerRecord, creates a group in the HDF5 file for it, and then writes all of the underlying data (`TriggerRecordHeader` and `Fragment`s) to appropriate datasets and subgroups. All data are written as dimension 1 `char` arrays, with no change to the input `TriggerRecord` object.

#### Reading
The constructor for creating a new HDF5RawDataFile for reading looks like this:
```
HDF5RawDataFile(const std::string& file_name);
```
There is no need to provide file layout parameters, as these are read from the existing file's attributes.

`dunedaq` raw data files can be interrogated with any HDF5 reading utilities, and the data payloads for each dataset are simple dimension 1 byte (`char`) arrays.
However, there are a number of useful accessors included in `HDF5RawDataFile` to aid in file interrogation, traversal, and data extraction:
- `get_dataset_paths(std::string top_level_group_name = "")` returns all dataset paths (`std::vector<std::string>`) located beneath the specified group (defaulting to the whole file), including the full list of datasets in any subgroups of the specified group;
- `get_all_record_ids()` returns an `std::set` of record IDs (std::pair of record number and sequence number) located in the file;
-  `get_trigger_record_header_dataset_paths(int max_trigger_records = -1)` returns all datset paths (up to a maximum number of desired trigger records, default is all) for `TriggerRecordHeader` objects;
-  `get_all_fragment_dataset_paths(int max_trigger_records = -1)` returns all datset paths (up to a maximum number of desired trigger records, default is all) for `Fragment` objects of any system type;
-  `get_trh_ptr(...)` members return a unique ptr to a `TriggerRecordHeader`, with inputs either being a full path as you may get from `get_trigger_record_header_dataset_paths()`, or with an input specifying the desired trigger number;
-  `get_frag_ptr(...)` members return a unique ptr to a `Fragment`, with inputs either being a full path as you would get from `get_all_fragment_dataset_paths()`, or by specifying the trigger number and `GeoID` of the desired data (or also the elements of the `GeoID`). 

# Version Notes

## Version 7 Notes

- Support for gzip compression was added with the `compression_level` parameter.
- Added the file attributes `uncompressed_raw_data_size` and `total_file_size`.
- Added getter methods `get_compression_level`, `get_uncompressed_raw_data_size`, and `get_total_file_size`.

## Version 6 Notes
- The data types of the `creation_timestamp` and `closing_timestamp` HDF5 File Attributes were changed from string to integer.

## Version 5 Notes
- The contents of the `TriggerRecordHeaderData` structure changed (support for additional trigger types was added), and it seemed prudent to update the `file_layout_version` to reflect this data format change.

## Version 4 Notes
- Updated the file format version from 3 to 4 in response to the SW_TriggerPrimitive-to-TriggerPrimitive data structure name change.

## Version 3 Notes
Extensive notes on the version 3 updates can be found [here](V3FileFormatInterfaceChanges.md).

## Version 2 Notes

This version is the initial version of `hdf5libs` after significant restructuring of many of the existing utilities, including the introduction of the `HDF5FileLayout` class, and separation of the `HDF5RawDataFile` class from `dfmodules`.

## Version 0 Notes
This version refers to files that were written before the introduction of the `HDF5FileLayout` class. Currently, on reading a file, if there is no file layout attributes found in the file, it assumes a file layout parameter set as such:
```
hdf5filelayout::FileLayoutParams flp;
    flp.trigger_record_name_prefix = "TriggerRecord";
    flp.digits_for_trigger_number = 6;
    flp.digits_for_sequence_number = 0;
    flp.trigger_record_header_dataset_name = "TriggerRecordHeader";

    hdf5filelayout::PathParams pp;

    pp.detector_group_type = "TPC";
    pp.detector_group_name = "TPC";
    pp.region_name_prefix = "APA";
    pp.digits_for_region_number = 3;
    pp.element_name_prefix = "Link";
    pp.digits_for_element_number = 2;
    flp.path_param_list.push_back(pp);

    pp.detector_group_type = "PDS";
    pp.detector_group_name = "PDS";
    pp.region_name_prefix = "Region";
    pp.digits_for_region_number = 3;
    pp.element_name_prefix = "Element";
    pp.digits_for_element_number = 2;
    flp.path_param_list.push_back(pp);

    pp.detector_group_type = "NDLArTPC";
    pp.detector_group_name = "NDLArTPC";
    pp.region_name_prefix = "Region";
    pp.digits_for_region_number = 3;
    pp.element_name_prefix = "Element";
    pp.digits_for_element_number = 2;
    flp.path_param_list.push_back(pp);

    pp.detector_group_type = "Trigger";
    pp.detector_group_name = "Trigger";
    pp.region_name_prefix = "Region";
    pp.digits_for_region_number = 3;
    pp.element_name_prefix = "Element";
    pp.digits_for_element_number = 2;
    flp.path_param_list.push_back(pp);

    pp.detector_group_type = "TPC_TP";
    pp.detector_group_name = "TPC";
    pp.region_name_prefix = "APA";
    pp.digits_for_region_number = 3;
    pp.element_name_prefix = "Link";
    pp.digits_for_element_number = 2;
    flp.path_param_list.push_back(pp);
```
Note that for all previously written files, `get_dataset_paths()` will work to retrieve a list of all proper dataset paths, and `get_trh_ptr(path_name)` and `get_frag_ptr(path_name)` will work for data access to `TriggerRecordHeader`s and `Fragment`s, respectively, where `path_name` is the full dataset path name. Other accessors to retrieving underlying data will throw an exception.



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Andrew Mogan_

_Date: Mon Apr 7 13:29:59 2025 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/hdf5libs/issues](https://github.com/DUNE-DAQ/hdf5libs/issues)_
</font>
