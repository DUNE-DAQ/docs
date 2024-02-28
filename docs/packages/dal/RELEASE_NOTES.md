
_JCF, Jan-23-2023: the following are the original ATLAS TDAQ release notes; they are not guaranteed to be applicable to the DUNE DAQ refactor of this repository_

# dal

## tdaq-09-01-00

### OKS git

When TDAQ_DB_REPOSITORY and TDAQ_DB_USER_REPOSTORY are defined, the DAL algorithm calculating environment sets TDAQ_DB_PATH=$TDAQ_DB_USER_REPOSTORY and usets TDAQ_DB_REPOSITORY and TDAQ_DB_USER_REPOSTORY process environment to allow standalone user tests.

### SW repository generation utility was removed

Remove dal_create_sw_repository. The create_repo.py has to be used instead. See [CMake TWiki](https://twiki.cern.ch/twiki/bin/viewauth/Atlas/DaqHltCMake#Software_Repository_Generation) for more information.

## tdaq-08-03-00

### New template-based segments and applications config
Jira: [ADTCC-177](https://its.cern.ch/jira/browse/ADTCC-177)

The generated DAL classes BaseApplication and Segment replaced old AppConfig and SegConfig ones.

Updated partition algorithms:
```
std::vector<const BaseApplication *> Partition::get_all_applications(std::set<std::string> * app_types = nullptr,
  std::set<std::string> * use_segments = nullptr, std::set<const Computer *> * use_hosts = nullptr) const;

const Segment * Partition::get_segment(const std::string& name) const;
```

The segment algorithms:
```
std::vector<const BaseApplication *> Segment::get_all_applications(std::set<std::string> * app_types = nullptr,
  std::set<std::string> * use_segments = nullptr, std::set<const Computer *> * use_hosts = nullptr) const;

const BaseApplication * Segment::get_controller() const;

const std::vector<const BaseApplication *>& Segment::get_infrastructure() const;

const std::vector<const BaseApplication *>& Segment::get_applications() const;

const std::vector<const Segment*>& Segment::get_nested_segments() const;

const std::vector<const Computer*>& Segment::get_hosts() const;

const Segment * Segment::get_base_segment() const;

bool Segment::is_disabled() const;

bool Segment::is_templated() const;

void Segment::get_timeouts(int & actionTimeout, int & shortActionTimeout) const;
``` 

The application algorithms:
```
const Computer * BaseApplication::get_host() const;

const daq::core::Segment * BaseApplication::get_segment() const;

std::vector<const daq::core::Computer *> BaseApplication::get_backup_hosts() const;

const daq::core::BaseApplication * BaseApplication::get_base_app() const;

std::vector<const daq::core::BaseApplication *>
BaseApplication::get_initialization_depends_from(const std::vector<const daq::core::BaseApplication *>& all_apps) const;

std::vector<const daq::core::BaseApplication *>
BaseApplication::get_shutdown_depends_from(const std::vector<const daq::core::BaseApplication *>& all_apps) const;
```

The algorithms on Segment and BaseApplication objects may only be called, if such objects in turn were instantiated by get_all_applications() or partition's get_segment() DAL algorithms.

### Algorithms changes
Jira: [ADTCC-209](https://its.cern.ch/jira/browse/ADTCC-209)

Several algorithms were never used and deleted or reorganized

#### Modified algorithms


* BaseApplication::get_output_error_directory() is renamed to Partition::get_log_directory() because the log directory does not depend on the application

* BaseApplication::get_info() remove partition, segment and host parameters

* Segment::get_timeouts() remove partition and database parameters

* SubstituteVariables remove database parameter in the constructor

#### Removed algorithms

Several algorithms were obsolete and deleted, or not used by user code and removed from public API:


* ComputerProgram::get_parameters()

* BaseApplication::get_application()

* BaseApplication::get_some_info()

* ResourceBase::get_applications()

* Variable::get_value(tag)

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Mon Jan 23 12:06:15 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dal/issues](https://github.com/DUNE-DAQ/dal/issues)_
</font>
