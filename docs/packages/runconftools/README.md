# runconftools

This python repository interfaces with the operation repositories that store the configurations used at EHN1. 
The configurations are generated from the base `ehn1-daqconfigs`, https://gitlab.cern.ch/dune-daq/online/ehn1-daqconfigs.
The scripts start from the base to construct the necessary operation branches, which are ultimately the configurations. 

This repository is intended for direct use by experts only. 
Shifters will use these interfaces indirectly via the shifter interface. 

## High level view
According to our configuration model, the different configurations to be used for operations are stored in different branches of operation repositories. 
There is one operation repository for each apparatus: `np02`, `np04`. To be decided if coldboxes will have their own separate repositories. 
The current repositores are https://gitlab.cern.ch/dune-daq/online/np02-configs-operation and https://gitlab.cern.ch/dune-daq/online/np04-configs-operations but NO ONE should interface directly with those repositories. 
Changes should only be performed using the interfaces of this package. 
The branches in the operation repoitories are derived using configuration generation functions (known as generators), starting from a base repository. 
The base repository contains both OKS objects and generators used to create operation configurations. 

## Configuration branches
The branches on the operation repositories are named as `<version>/<configuration_key>`. 
For stable configurations, `<version>` is in the form of `fddaq-v5.x.y` (e.g. `fdddaq-v5.2.2`), but in general it can be any string specified at the time that the generators are executed. 
The `<configuration_key>` is the name of the generator used to create the configuration. 

Here are some examples:
 - `develop/monitoring-with-tpg` is the configuration called `monitoring-with-tpg` compatible with the OKS schema published with the nightly build including the develop branches used at the time of generation.
 - `fddaq-v5.2.2/daphne-fullstream` is the configuration called `daphne-fullstream` to be used with DAQ version v5.2.2. Note that this is used also for prep-relase branches and release candidate of the DAQ for v5.2.2. 
 - `mroda-test/monitoring-no-tpg` is a temporary configuration that might eventually replace the current `monitoring-no-tpg` pending testing. These temporary branches should be created if a particular configuration must be tested from the shifter.
   This is necessary as the shifter interface only sees whatever is stored in the operation repo. 


## Installation
This is a python package, so just checkout the repo and call
```bash
cd runconftools
pip install .
```
Please remember that this requires the proxy from EHN1 machines. 

## Scripts 
This repository provides the following scripts.
All script names start with `cpm-`, which stands for Configuration Pool Management.


### cpm-setup 
This is a diagnostic script designed to setup a local area linked to both base and operation repostiories and to print some information about the configurations.

```bash
Usage: cpm-setup [OPTIONS] PATH

  Set up a local repo and prints some informations.  If the conf option is
  specified, the relevant configuration from operation is checked out for
  inspection.

Options:
  -a, --apparatus [np02|np04]  Selection of the apparatus  [default: np02]
  --base_url TEXT              [default: https://gitlab.cern.ch/dune-
                               daq/online/ehn1-daqconfigs.git]
  --operation_url TEXT
  -r, --release TEXT           [default: fddaq-v5.2.2]
  -b, --base TEXT              If None, it is set equal to the release
  -c, --conf TEXT
  --debug                      Set debug print levels
  --help                       Show this message and exit.
```

The `PATH` must be an existing location and has to be either empty or a valid `ehn1-daqconfigs` repository. 
If the directory contains a local repository, local changes may be lost so please push all changes that are important before calling `cpm-setup` on a non-empty directory.

This script sets up a git repository and prints some information about the release. 

The information printed is:
 - The list of available branches in the base, without any filtering;
 - The list of available releases in operation;
 - The list of available generators in the selected base;
 - The list of configurations in the operation repository for the selected release;
 - The list of verifiers called once a configuration is generated.

### cpm-update
This is the script that takes a base branch and propagates the changes to the operation repo, creating the necessary configurations. 

```bash
Usage: cpm-update [OPTIONS] PATH

  This script takes the a base branch and propagates the changes to the
  operation repo, creating the necessary configurations. As a default, the
  branches are not pushed, use -p  or --push-only to perform the push

Options:
  -a, --apparatus [np02|np04]  Selection of the apparatus  [default: np02]
  --base_url TEXT              Git location of the remote base repo  [default:
                               ssh://git@gitlab.cern.ch:7999/dune-
                               daq/online/ehn1-daqconfigs.git]
  --operation_url TEXT         Git location of the remote operation repo. If
                               None, the repo is set according to the
                               apparatus
  -b, --base TEXT              Base branch to be used as a starting point
                               [default: fddaq-v5.2.2]
  -r, --release TEXT           Operation branch prefix for the generated
                               branches  [default: fddaq-v5.2.2]
  --conf TEXT                  Regex to select a subset of generators
                               [default: .*]
  --push-only                  When set, it only pushes local branches,
                               without regenerating
  -p, --push                   Pushes the branhces, otherwise they are only
                               created locally
  --debug                      Set debug print levels
  --help                       Show this message and exit.
```

As for the setup, `PATH` has to be an existing location and has to be either empty or a valid `ehn1-configs` repository. 
As previously, ensure local changes are pushed before using an existing path with this script.
It is recommended that a new directory is created for the operation. 
It can be deleted once the propagation is complete. 

The script starts by checking out the required base. 
Then, for every generator in the base, it creates the branches using the `release` option as `version` to be used in the branch name. 
The generators to be executed are selected using a regex with the option `conf`. 
For example
```bash
cpm-update -r mroda --conf "^monitoring-.*$" Test
```
will create branches called `mroda/monitoring-<something>` and will ignore all the other generators.

When generators are executed, so are the configuration verifiers, 
If present, the configuraiton validator associated to the generator is also executed. 
If any verifiers or validators fail, the branch is still created and committed, but they are not pushed to the operation, even if requested. 
This will allow local persistency to investigate the issue. 

By default, the script does not push.
This is done explicitly with the `-p` option.
After a local geneation, `cpm-update` can be followed up with another call with the `--push-only` which pushes the local branches corresponding to the existing generators. 


### cpm-purge
Sometimes temporary branches must be pushed to operation repositories as they need to be tested through the shifter interface.
Once the test is done the branches should be removed with `cpm-purge`.
This is done with `cpm-purge`
```bash
Usage: cpm-purge [OPTIONS] PATH

  This script removes from the operation repo the selected configurations for
  a given release

Options:
  -a, --apparatus [np02|np04]  Selection of the apparatus  [default: np02]
  --base_url TEXT              Git location of the remote base repo  [default:
                               ssh://git@gitlab.cern.ch:7999/dune-
                               daq/online/ehn1-daqconfigs.git]
  --operation_url TEXT         Git location of the remote operation repo. If
                               None, the repo is set according to the
                               apparatus
  -r, --release TEXT           Operation branch prefix for the branches to be
                               deleted
  --conf TEXT                  Regex to select a subset of branches  [default:
                               .*]
  --debug                      Set debug print levels
  --help                       Show this message and exit.
```

This removes the branches with for a specified release.
As for the update script, the configuration keys can be selected using a regex with the option `--conf`. 

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: MRiganSUSX_

_Date: Tue Apr 8 12:49:40 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/runconftools/issues](https://github.com/DUNE-DAQ/runconftools/issues)_
</font>
