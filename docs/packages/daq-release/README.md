# About daq-release

[![AL9 Spack Nightly Workflow (dev, v5) ](https://github.com/DUNE-DAQ/daq-release/actions/workflows/build-nightly-release-alma9.yml/badge.svg)](https://github.com/DUNE-DAQ/daq-release/actions/workflows/build-nightly-release-alma9.yml)

[![Nightly v5 Integration Test Workflow](https://github.com/DUNE-DAQ/daq-release/actions/workflows/nightly-v5-integtest.yml/badge.svg)](https://github.com/DUNE-DAQ/daq-release/actions/workflows/nightly-v5-integtest.yml)

This is a repo containing DUNE DAQ release making tools, configuration files, and build scripts for both DUNE-DAQ and external packages. 

## Table of contents

### For DAQ software developers and users:


1. [DAQ software development workflow](development_workflow_gitflow.md)


2. [List of GitHub Teams and Repositories](team_repos.md)


3. [How to build a package with Spack in a local workarea](Build-packages-with-spack-in-a-work-area.md)

### For the Software Coordination team (expert only):



1. [Nightly Releases and Continuous Integration](ci_github_action.md)


2. [Creating a new DAQ release](create_release_spack.md)


3. [How to publish files to cvmfs](publish_to_cvmfs.md)


4. [How to build a new stack of external software](Build-new-external-software-stack.md)

# Single-Repo CI Build Status

appmodel: [![appmodel](https://github.com/DUNE-DAQ/appmodel/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/appmodel/actions/workflows/dunedaq-develop-cpp-ci.yml)

appfwk: [![appfwk](https://github.com/DUNE-DAQ/appfwk/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/appfwk/actions/workflows/dunedaq-develop-cpp-ci.yml)

cmdlib: [![cmdlib](https://github.com/DUNE-DAQ/cmdlib/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/cmdlib/actions/workflows/dunedaq-develop-cpp-ci.yml)

confmodel: [![confmodel](https://github.com/DUNE-DAQ/confmodel/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/confmodel/actions/workflows/dunedaq-develop-cpp-ci.yml)

daq-cmake: [![daq-cmake](https://github.com/DUNE-DAQ/daq-cmake/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/daq-cmake/actions/workflows/dunedaq-develop-cpp-ci.yml)

daqconf: [![daqconf](https://github.com/DUNE-DAQ/daqconf/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/daqconf/actions/workflows/dunedaq-develop-cpp-ci.yml)

daqdataformats: [![daqdataformats](https://github.com/DUNE-DAQ/daqdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/daqdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml)

dbe: [![dbe](https://github.com/DUNE-DAQ/dbe/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/dbe/actions/workflows/dunedaq-develop-cpp-ci.yml)

detchannelmaps: [![detchannelmaps](https://github.com/DUNE-DAQ/detchannelmaps/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/detchannelmaps/actions/workflows/dunedaq-develop-cpp-ci.yml)

detdataformats: [![detdataformats](https://github.com/DUNE-DAQ/detdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/detdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml)

dfmessages: [![dfmessages](https://github.com/DUNE-DAQ/dfmessages/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/dfmessages/actions/workflows/dunedaq-develop-cpp-ci.yml)

dfmodules: [![dfmodules](https://github.com/DUNE-DAQ/dfmodules/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/dfmodules/actions/workflows/dunedaq-develop-cpp-ci.yml)

dpdklibs: [![dpdklibs](https://github.com/DUNE-DAQ/dpdklibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/dpdklibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

ers: [![ers](https://github.com/DUNE-DAQ/ers/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/ers/actions/workflows/dunedaq-develop-cpp-ci.yml)

erskafka: [![erskafka](https://github.com/DUNE-DAQ/erskafka/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/erskafka/actions/workflows/dunedaq-develop-cpp-ci.yml)

fddaqconf: [![fddaqconf](https://github.com/DUNE-DAQ/fddaqconf/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/fddaqconf/actions/workflows/dunedaq-develop-cpp-ci.yml)

fddetdataformats: [![fddetdataformats](https://github.com/DUNE-DAQ/fddetdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/fddetdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml)

fdreadoutlibs: [![fdreadoutlibs](https://github.com/DUNE-DAQ/fdreadoutlibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/fdreadoutlibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

fdreadoutmodules: [![fdreadoutmodules](https://github.com/DUNE-DAQ/fdreadoutmodules/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/fdreadoutmodules/actions/workflows/dunedaq-develop-cpp-ci.yml)

flxlibs: [![flxlibs](https://github.com/DUNE-DAQ/flxlibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/flxlibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

oksdalgen: [![oksdalgen](https://github.com/DUNE-DAQ/oksdalgen/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/oksdalgen/actions/workflows/dunedaq-develop-cpp-ci.yml)

hdf5libs: [![hdf5libs](https://github.com/DUNE-DAQ/hdf5libs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/hdf5libs/actions/workflows/dunedaq-develop-cpp-ci.yml)

hermesmodules: [![hermesmodules](https://github.com/DUNE-DAQ/hermesmodules/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/hermesmodules/actions/workflows/dunedaq-develop-cpp-ci.yml)

hsilibs: [![hsilibs](https://github.com/DUNE-DAQ/hsilibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/hsilibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

iomanager: [![iomanager](https://github.com/DUNE-DAQ/iomanager/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/iomanager/actions/workflows/dunedaq-develop-cpp-ci.yml)

ipm: [![ipm](https://github.com/DUNE-DAQ/ipm/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/ipm/actions/workflows/dunedaq-develop-cpp-ci.yml)

kafkaopmon: [![kafkaopmon](https://github.com/DUNE-DAQ/kafkaopmon/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/kafkaopmon/actions/workflows/dunedaq-develop-cpp-ci.yml)

listrev: [![listrev](https://github.com/DUNE-DAQ/listrev/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/listrev/actions/workflows/dunedaq-develop-cpp-ci.yml)

logging: [![logging](https://github.com/DUNE-DAQ/logging/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/logging/actions/workflows/dunedaq-develop-cpp-ci.yml)

oks: [![oks](https://github.com/DUNE-DAQ/oks/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/oks/actions/workflows/dunedaq-develop-cpp-ci.yml)

opmonlib: [![opmonlib](https://github.com/DUNE-DAQ/opmonlib/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/opmonlib/actions/workflows/dunedaq-develop-cpp-ci.yml)

rawdatautils: [![rawdatautils](https://github.com/DUNE-DAQ/rawdatautils/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/rawdatautils/actions/workflows/dunedaq-develop-cpp-ci.yml)

rcif: [![rcif](https://github.com/DUNE-DAQ/rcif/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/rcif/actions/workflows/dunedaq-develop-cpp-ci.yml)

restcmd: [![restcmd](https://github.com/DUNE-DAQ/restcmd/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/restcmd/actions/workflows/dunedaq-develop-cpp-ci.yml)

serialization: [![serialization](https://github.com/DUNE-DAQ/serialization/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/serialization/actions/workflows/dunedaq-develop-cpp-ci.yml)

sspmodules: [![sspmodules](https://github.com/DUNE-DAQ/sspmodules/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/sspmodules/actions/workflows/dunedaq-develop-cpp-ci.yml)

timing: [![timing](https://github.com/DUNE-DAQ/timing/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/timing/actions/workflows/dunedaq-develop-cpp-ci.yml)

timinglibs: [![timinglibs](https://github.com/DUNE-DAQ/timinglibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/timinglibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

tpglibs: [![tpglibs](https://github.com/DUNE-DAQ/tpglibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/tpglibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

trgdataformats: [![trgdataformats](https://github.com/DUNE-DAQ/trgdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/trgdataformats/actions/workflows/dunedaq-develop-cpp-ci.yml)

trigger: [![trigger](https://github.com/DUNE-DAQ/trigger/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/trigger/actions/workflows/dunedaq-develop-cpp-ci.yml)

triggeralgs: [![triggeralgs](https://github.com/DUNE-DAQ/triggeralgs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/triggeralgs/actions/workflows/dunedaq-develop-cpp-ci.yml)

uhallibs: [![uhallibs](https://github.com/DUNE-DAQ/uhallibs/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/uhallibs/actions/workflows/dunedaq-develop-cpp-ci.yml)

utilities: [![utilities](https://github.com/DUNE-DAQ/utilities/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/utilities/actions/workflows/dunedaq-develop-cpp-ci.yml)

wibmod: [![wibmod](https://github.com/DUNE-DAQ/wibmod/actions/workflows/dunedaq-develop-cpp-ci.yml/badge.svg)](https://github.com/DUNE-DAQ/wibmod/actions/workflows/dunedaq-develop-cpp-ci.yml)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Dune_

_Date: Wed Oct 16 14:03:52 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-release/issues](https://github.com/DUNE-DAQ/daq-release/issues)_
</font>
