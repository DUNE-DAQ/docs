# V3FileFormatInterfaceChanges
## HDF5RawDataFile interface changes for file format version 3


**DRAFT** 

As mentioned in the Overview, the `HDF5RawDataFile` C++ class is the main interface in the _hdf5libs_ package for writing and reading HDF files.

The changes associated with the introduction of _SourceIDs_ in _dunedaq-v3.2.0_ affects the HDF5 file layout and, to a lesser extent, the `HDF5RawDataFile` C++ interface.  The file layout version increases from 2 to 3 as part of this transition.

Many of the methods in the `HDF5RawDataFile` interface do *not* change for file layout version 3, and those are listed in the first table below.  The second table has rows that list each of the methods that *have* changed and the new method signature.  And, the third table lists new methods that become available with the introduction of SourceIDs in the DAQ data.

Note that type `record_id_t` is defined as `std::pair<uint64_t, daqdataformats::sequence_number_t>`.

### `HDF5RawDataFile` C++ methods that did *not* change between file format version 2 and version 3

Note that in some cases, some of the detail of a method signature may have been omitted to save space (e.g. `const` declarations, full namespace details, etc.)  Please see the latest version of the `HDF5RawDataFile.hpp` header file for the full details.

| Unchanged HDF5RawDataFile methods |
| --- | 
| [file read constructor]  HDF5RawDataFile(const std::string& file_name) |
| std::string get_file_name() |
| size_t get_recorded_size() |
| std::string get_record_type() |
| bool is_trigger_record_type() |
| bool is_timeslice_type() |
| HDF5FileLayout get_file_layout() |
| uint32_t get_version() |
| void write(const daqdataformats::TriggerRecord& tr) |
| void write(const daqdataformats::TimeSlice& ts) |
| template&lt;typename T&gt; void write_attribute(const std::string& name, T value) |
| template&lt;typename T&gt; void write_attribute(HighFive::Group& grp, const std::string& name, T value) |
| template&lt;typename T&gt; void write_attribute(HighFive::DataSet& dset, const std::string& name, T value) |
| template&lt;typename T&gt; T get_attribute(const std::string& name) |
| template&lt;typename T&gt; T get_attribute(const HighFive::Group& grp, const std::string& name) |
| template&lt;typename T&gt; T get_attribute(const HighFive::DataSet& dset, const std::string& name) |
| std::vector&lt;std::string&gt; get_dataset_paths(std::string top_level_group_name = "") |
| record_id_set get_all_record_ids() |
| record_id_set get_all_trigger_record_ids() |
| record_id_set get_all_timeslice_ids() |
| std::set&lt;uint64_t&gt; get_all_record_numbers() // deprecated |
| std::set&lt;daqdataformats::trigger_number_t&gt; get_all_trigger_record_numbers() // deprecated |
| std::set&lt;daqdataformats::timeslice_number_t&gt; get_all_timeslice_numbers() // deprecated |
| std::vector&lt;std::string&gt; get_record_header_dataset_paths() |
| std::vector&lt;std::string&gt; get_trigger_record_header_dataset_paths() |
| std::vector&lt;std::string&gt; get_timeslice_header_dataset_paths() |
| std::string get_record_header_dataset_path(record_id_t& rid) |
| std::string get_record_header_dataset_path(uint64_t rec_num, daqdataformats::sequence_number_t seq_num; |
| std::string get_trigger_record_header_dataset_path(record_id_t& rid) |
| std::string get_trigger_record_header_dataset_path(daqdataformats::trigger_number_t trig_num, daqdataformats::sequence_number_t seq_num)
| std::string get_timeslice_header_dataset_path(record_id_t& rid) |
| std::string get_timeslice_header_dataset_path(daqdataformats::timeslice_number_t trig_num) |
| std::vector&lt;std::string&gt; get_all_fragment_dataset_paths() |
| std::vector&lt;std::string&gt; get_fragment_dataset_paths(record_id_t& rid) |
| std::vector&lt;std::string&gt; get_fragment_dataset_paths(uint64_t rec_num, daqdataformats::sequence_number_t seq_num) |
| std::unique_ptr&lt;char[]&gt; get_dataset_raw_data(std::string& dataset_path) |
| std::unique_ptr&lt;daqdataformats::Fragment&gt;            get_frag_ptr(std::string& dataset_name) |
| std::unique_ptr&lt;daqdataformats::TriggerRecordHeader&gt; get_trh_ptr(std::string& dataset_name) |
| std::unique_ptr&lt;daqdataformats::TimeSliceHeader&gt;     get_tsh_ptr(std::string& dataset_name) |
| std::unique_ptr&lt;daqdataformats::TriggerRecordHeader&gt; get_trh_ptr(record_id_t& rid) |
| std::unique_ptr&lt;daqdataformats::TriggerRecordHeader&gt; get_trh_ptr(daqdataformats::trigger_number_t trig_num, daqdataformats::sequence_number_t seq_num) |
| std::unique_ptr&lt;daqdataformats::TimeSliceHeader&gt; get_tsh_ptr(record_id_t& rid) |
| std::unique_ptr&lt;daqdataformats::TimeSliceHeader&gt; get_tsh_ptr(daqdataformats::timeslice_number_t ts_num) |
| daqdataformats::TriggerRecord get_trigger_record(record_id_t rid) |
| daqdataformats::TriggerRecord get_trigger_record(daqdataformats::trigger_number_t trig_num,daqdataformats::sequence_number_t seq_num) |
| daqdataformats::TimeSlice get_timeslice(record_id_t rid) |
| daqdataformats::TimeSlice get_timeslice(daqdataformats::timeslice_number_t ts_num) |


### `HDF5RawDataFile` C++ interface changes between file format version 2 and version 3:

Note that in some cases, some of the detail of a method signature may have been omitted to save space (e.g. `const` declarations, full namespace details, etc.)  Please see the latest version of the `HDF5RawDataFile.hpp` header file for the full details.


| Version 2 method | Corresponding Version 3 method |
| ---- | ---- |
| [file write constructor] HDF5RawDataFile(std::string file_name, ..., unsigned open_flags) | HDF5RawDataFile(..., std::shared_ptr&lt;HardwareMapService&gt; hw_map_service, ...) | 
| (public) void write(TriggerRecordHeader&) | (private) HighFive::Group write(TriggerRecordHeader&, HDF5SourceIDHandler::source_id_path_map_t&) |
| (public) void write(TimeSliceHeader&) | (private) HighFive::Group write(TimeSliceHeader&, HDF5SourceIDHandler::source_id_path_map_t&) |
| (public) void write(Fragment&) | (private) HighFive::Group write(Fragment&, HDF5SourceIDHandler::source_id_path_map_t&) |
| vector&lt;string&gt; get_fragment_dataset_paths(daqdataformats::GeoID::SystemType type) | vector&lt;string&gt; get_fragment_dataset_paths(detdataformats::DetID::Subdetector subdet) |
| vector&lt;string&gt; get_fragment_dataset_paths(std::string typestring) | vector&lt;string&gt; get_fragment_dataset_paths(string& subdetector_name) |
| vector&lt;string&gt; get_fragment_dataset_paths(record_id_t, daqdataformats::GeoID::SystemType) | vector&lt;string&gt; get_fragment_dataset_paths(record_id_t, detdataformats::DetID::Subdetector) |
| vector&lt;string&gt; get_fragment_dataset_paths(record_id_t, std::string typestring) | vector&lt;string&gt; get_fragment_dataset_paths(record_id_t, string& subdetector_name) |
| vector&lt;string&gt; get_fragment_dataset_paths(daqdataformats::GeoID element_id) | vector&lt;string&gt; get_fragment_dataset_paths(uint64_t geoid) | 
| vector&lt;string&gt; get_fragment_dataset_paths(daqdataformats::GeoID::SystemType type, uint16_t region_id, uint32_t element_id) | vector&lt;string&gt; get_fragment_dataset_paths(detdataformats::DetID::Subdetector det_id, uint16_t det_crate, uint16_t det_slot, uint16_t det_link) |
| vector&lt;string&gt; get_fragment_dataset_paths(string typestring, uint16_t region_id, uint32_t element_id) | vector&lt;string&gt; get_fragment_dataset_paths(std::string subdetector_name, uint16_t det_crate, uint16_t det_slot, uint16_t det_link) |
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(vector&lt;string&gt; frag_dataset_paths) | std::set&lt;uint64_t&gt; get_geo_ids(vector&lt;string&gt; frag_dataset_paths) |
| std::set&lt;daqdataformats::GeoID&gt; get_all_geo_ids() | std::set&lt;uint64_t&gt; get_all_geo_ids() | 
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(record_id_t rid) | std::set&lt;uint64_t&gt; get_geo_ids(record_id_t rid) |
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num | std::set&lt;uint64_t&gt; get_geo_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num |
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(record_id_t, daqdataformats::GeoID::SystemType) | std::set&lt;uint64_t&gt; get_geo_ids(record_id_t, detdataformats::DetID::Subdetector) | 
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(record_id_t, string typestring) | std::set&lt;uint64_t&gt; get_geo_ids(record_id_t, string subdetector_name)
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::GeoID::SystemType type) | std::set&lt;uint64_t&gt; get_geo_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, detdataformats::DetID::Subdetector subdet)
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, string typestring) | std::set&lt;uint64_t&gt; get_geo_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, string subdetector_name) |
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(daqdataformats::GeoID::SystemType type) | std::set&lt;uint64_t&gt; get_geo_ids(detdataformats::DetID::Subdetector subdet) | 
| std::set&lt;daqdataformats::GeoID&gt; get_geo_ids(std::string typestring) | std::set&lt;uint64_t&gt; get_geo_ids(std::string subdetector_name) |
| unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t rid, daqdataformats::GeoID element_id) | unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t rid, uint64_t geoid) |
| unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::GeoID element_id) | unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, uint64_t geo_id) | 
| unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t rid, daqdataformats::GeoID::SystemType type, uint16_t region_id, uint32_t element_id) | unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t rid, detdataformats::DetID::Subdetector det_id, uint16_t det_crate, uint16_t det_slot, uint16_t det_link) |
| unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::GeoID::SystemType type, uint16_t region_id, uint32_t element_id) | unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, detdataformats::DetID::Subdetector det_id, uint16_t det_crate, uint16_t det_slot, uint16_t det_link) |
| unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t rid, string typestring, uint16_t region_id, uint32_t element_id) |unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t rid, string subdetector_name, uint16_t det_crate, uint16_t det_slot, uint16_t det_link) |
| unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, string typestring, uint16_t region_id, uint32_t element_id) | unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, string subdetector_name, uint16_t det_crate, uint16_t det_slot, uint16_t det_link) |

### `HDF5RawDataFile` C++ methods that were added for file format version 3

Note that in some cases, some of the detail of a method signature may have been omitted to save space (e.g. `const` declarations, full namespace details, etc.)  Please see the latest version of the `HDF5RawDataFile.hpp` header file for the full details.

| New HDF5RawDataFile methods |
| --- |
| std::set<daqdataformats::SourceID> get_source_ids(record_id_t& rid) |
| std::set<daqdataformats::SourceID> get_source_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num) |
| daqdataformats::SourceID get_record_header_source_id(record_id_t& rid) |
| daqdataformats::SourceID get_record_header_source_id(uint64_t rec_num, daqdataformats::sequence_number_t seq_num) |
| std::set<daqdataformats::SourceID> get_fragment_source_ids(record_id_t& rid) |
| std::set<daqdataformats::SourceID> get_fragment_source_ids(uint64_t rec_num, daqdataformats::sequence_number_t seq_num) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subsystem(record_id_t& rid, daqdataformats::SourceID::Subsystem subsystem) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subsystem(record_id_t& rid, std::string& subsystem_name) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subsystem(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::SourceID::Subsystem subsystem) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subsystem(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, std::string& subsystem_name) |
| std::set<daqdataformats::SourceID> get_source_ids_for_fragment_type(record_id_t& rid, daqdataformats::FragmentType frag_type) |
| std::set<daqdataformats::SourceID> get_source_ids_for_fragment_type(record_id_t& rid, std::string& frag_type_name) |
| std::set<daqdataformats::SourceID> get_source_ids_for_fragment_type(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::FragmentType frag_type) |
| std::set<daqdataformats::SourceID> get_source_ids_for_fragment_type(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, std::string& frag_type_name) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subdetector(record_id_t& rid, detdataformats::DetID::Subdetector subdet) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subdetector(record_id_t& rid, std::string& subdet_name) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subdetector(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, detdataformats::DetID::Subdetector subdet) |
| std::set<daqdataformats::SourceID> get_source_ids_for_subdetector(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, std::string& subdet_name) |
| std::unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t& rid, daqdataformats::SourceID& source_id) |
| std::unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::SourceID& source_id) |
| std::unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t& rid, daqdataformats::SourceID::Subsystem type, uint32_t id) |
| std::unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, daqdataformats::SourceID::Subsystem type, uint32_t id);
| std::unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(record_id_t& rid, std::string& subsystem_name, uint32_t id) |
| std::unique_ptr&lt;daqdataformats::Fragment&gt; get_frag_ptr(uint64_t rec_num, daqdataformats::sequence_number_t seq_num, std::string& subsystem_name, uint32_t id) |
| std::vector&lt;uint64_t&gt; get_geo_ids_for_source_id(record_id_t& rid, daqdataformats::SourceID& source_id) |
| daqdataformats::SourceID get_source_id_for_geo_id(record_id_t& rid, uint64_t geo_id) |


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Tue Sep 6 14:02:24 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/hdf5libs/issues](https://github.com/DUNE-DAQ/hdf5libs/issues)_
</font>
