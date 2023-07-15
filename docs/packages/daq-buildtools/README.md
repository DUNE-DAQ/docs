# DUNE DAQ Buildtools

_This document was last edited Jul-15-2023_

`daq-buildtools` is the toolset to simplify the development of DUNE DAQ packages. It provides environment and building utilities for the DAQ Suite.

## System requirements

To get set up, you'll need access to the cvmfs areas `/cvmfs/dunedaq.opensciencegrid.org` and `/cvmfs/dunedaq-development.opensciencegrid.org`. This is the case, e.g., on the np04 cluster at CERN. If you've been doing your own Spack work on the
system in question, you may also want to back up (rename) your
existing `~/.spack` directory to give Spack a clean slate to start
from in these instructions.

<a name="Setup_of_daq-buildtools"></a>
## Setup of `daq-buildtools`

Simply do:
```
source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh
setup_dbt fddaq-v4.1.0  
```
Here `fddaq-v4.1.0` is an alias for `v7.2.1`; this is the latest daq-buildtools version as of Jul-15-2023.
After running these two commands, then you'll see something like:
```
Added /cvmfs/dunedaq.opensciencegrid.org/tools/dbt/v7.2.1/bin -> PATH
Added /cvmfs/dunedaq.opensciencegrid.org/tools/dbt/v7.2.1/scripts -> PATH
DBT setuptools loaded
```
If you type `dbt-` followed by the `<tab>` key you'll see a listing of available commands, which include `dbt-create`, `dbt-build`, `dbt-setup-release` and `dbt-workarea-env`. These are all described in the following sections. 

Each time that you log into a fresh Linux shell and want to either (1) set up an existing cvmfs-based DUNE DAQ software release or (2) develop code within a pre-existing DUNE DAQ work area, you'll need to set up daq-buildtools. These two cases are described in detail momentarily. For (1) you'd want to repeat the method above to set up daq-buildtools. For (2) it's easier instead to `cd` into the work area and source the file named `env.sh`. 

<a name="Running_a_release_from_cvmfs"></a>
## Running a release from cvmfs

If you only want access to a DUNE DAQ software release (its executables, etc.) without actually developing DUNE DAQ software itself, you'll want to run a release from cvmfs. Please note that in general, frozen releases (especially patch frozen releases) are intended for this scenario, and _not_ for development. After setting up daq-buildtools, you can simply run the following command if you wish to use a frozen release:

```sh
dbt-setup-release <release> # fddaq-v4.1.0 the latest frozen release as of Jul-15-2023
```
As of July 2023, the DUNE DAQ software stack has been split into far detector and near detector-specific parts. Starting with the `v4.1.0` release of the stack, do _not_ use the traditional convention of `dunedaq-vX.Y.Z` as the frozen release label, but instead, `fddaq-vX.Y.Z` and `nddaq-vX.Y.Z`. Note that for `v4.1.0` we only have a far detector-specific stack. 

Instead of a frozen release you can also set up nightly releases or candidate releases using the same arguments as are described later for `dbt-create`; e.g. if you want to set up candidate release `fd-v4.1.0-c5` you can do:
```
dbt-setup-release -b candidate fd-v4.1.0-c5
```

`dbt-setup-release` will set up both the external packages and DAQ packages, as well as activate the Python virtual environment. Note that the Python virtual environment activated here is read-only. 

<a name="Creating_a_work_area"></a>
## Creating a work area

If you wish to develop DUNE DAQ software, you can start by creating a work area. Find a directory in which you want your work area to be a subdirectory (home directories are a popular choice) and `cd` into that directory. Then think of a good name for the work area (give it any name, but we'll refer to it as "MyTopDir" in this document).

Each work area is based on a DUNE DAQ software release, which defines what external and DUNE DAQ packages the code you develop in a work area are built against. Releases come in four categories:

* **Nightly Releases**: packages in nightly releases are built each night using the heads of their `develop` branches. Depending on whether it's the far detector stack or the near detector stack, these are generally labeled either as `NFD<YY>-<MM>-<DD>` (far detector) or `NND<YY>-<MM>-<DD>` (near detector). E.g. `NFD23-07-15` is the nightly build for the far detector on July 15, 2023.

* **Frozen Releases**: a frozen release typically comes out every couple of months, and only after extensive testing supervised by a Release Coordinator. Depending on whether it's the far detector stack or the near detector stack, labeled as `fddaq-vX.Y.X` or `nddaq-vX.Y.Z`. 

* **Candidate Releases**: a type of release meant specifically for frozen release testing. Generally labeled as `fd-vX.Y.Z-<candidate iteration>` or `nd-vX.Y.Z-<candidate iteration>`, e.g. `fd-v4.1.0-c5`

The majority of work areas are set up to build against the most recent nightly release. To do so, run:
```sh
dbt-create -n <nightly release> <name of work area subdirectory> # E.g., NFD23-07-15
```
To see all available nightly releases, run `dbt-create -l -n` or `dbt-create -l -b nightly`.

If you want to build against a candidate release, run:
```sh
dbt-create -b candidate <candidate release> <name of work area subdirectory> # E.g., fd-v4.1.0-c5 
```
...where to see all available candidate releases, run `dbt-create -l -b candidate`.

And to build against a frozen release (_not recommended_, as the codebase changes fairly rapidly), you don't need the `-b <release type>` argument at all. You can just do:
```
dbt-create <frozen release> <name of work area subdirectory> 
```

The structure of your work area will look like the following:
```txt
MyTopDir
├── build
├── dbt-workarea-constants.sh
├── env.sh
├── log
└── sourcecode
    ├── CMakeLists.txt
    └── dbt-build-order.cmake
```
The next section of this document concerns how to build code in your new work area. However, if you'd like to learn about how to retrieve information about your work area such as the release of the DUNE DAQ suite it builds against, you can skip ahead to [Finding Info on Your Work Area](#Finding_Info).

### Advanced `dbt-create` options

Along with telling `dbt-create` what you want your work area to be named and what release you want it to be based off of, there are a few more options that give you finer-grained control over the work area. You can simply run `dbt-create -h` for a summary, but they're described in fuller detail here.


* `-s/--spack`: Install a local Spack instance in the work area. This will allow you to install and load whatever Spack packages you wish into your work area. 


* `-c/--clone-pyvenv`: By default, the Python virtual environment your work area uses is in the release area on cvmfs. However, if you choose this option, `dbt-create` will actually copy this virtual environment over to your work area, thereby giving you write permission.
  

* `-i/--install-pyvenv`: With this option, there will be compilation/installation of python modules using the `pyvenv_requirements.txt` in the release directory. This is typically slower than cloning, but not always. You can take further control by combining it with the `-p <requirements file>` argument, though it's unlikely as a typical developer that you'd want a non-standard set of Python packages. 


<a name="Cloning_and_building"></a>
## Cloning and building a package repo

### The basics

First step: `cd` into the base of the work area you've created. 

For the purposes of instruction, let's build the `listrev` package. Downloading it is simple:
```
cd sourcecode
git clone https://github.com/DUNE-DAQ/listrev.git
cd ..
```

Note that in a "real world" situation [you'd be doing your development on a feature branch](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/development_workflow_gitflow/) in which case you'd add `-b <branch you want to work on>` to the `git clone` command above. 


We're about to build and install the `listrev` package. (&#x1F534; Note: if you are working with other packages, have a look at the [Working with more repos](#working-with-more-repos) subsection before running the following build command.) By default, the scripts will create a subdirectory of MyTopDir called `./install ` and install any packages you build off your repos there. If you wish to install them in another location, you'll want to set the environment variable `DBT_INSTALL_DIR` to the desired installation path before source-ing the `env.sh` script described below. You'll also want to remember to set the variable during subsequent logins to the work area if you don't go with the default. 

Now, do the following:
```sh
. ./env.sh  # To set up your work area's environment
dbt-build
```
...and this will build `listrev` in the local `./build` subdirectory and then install it as a package either in the local `./install` subdirectory or in whatever you pointed `DBT_INSTALL_DIR` to. `env.sh` performs two steps: it will both set up the daq-buildtools environment (if it hasn't already been set) and then it will update environment variables (`LD_LIBRARY_PATH`, etc.) to account for the packages in your work area. Note that whenever you add a new repo to your work area, you'll want to run the second of these two steps, `dbt-workarea-env`, so that environment variables such as `LD_LIBRARY_PATH`, etc, are again updated accordingly. 


### Working with more repos

To work with more repos, add them to the `./sourcecode` subdirectory as we did with listrev. Be aware, though: if you're developing a new repo which itself depends on another new repo, daq-buildtools may not already know about this dependency. "New" in this context means "not listed in `/cvmfs/dunedaq.opensciencegrid.org/spack/releases/fddaq-v4.1.0/dbt-build-order.cmake`". If this is the case, add the names of your new package(s) to the `build_order` list found in `./sourcecode/dbt-build-order.cmake`, placing them in the list in the relative order in which you want them to be built. 

As a reminder, once you've added your repos and built them, you'll want to run `dbt-workarea-env` so the environment picks up their applications, libraries, etc. 

### Useful build options

`dbt-build` will by default skip CMake's config+generate stages and go straight to the build stage _unless_ either the `CMakeCache.txt` file isn't found in `./build` or you've just added a new repo to `./sourcecode`. If you want to remove all the contents of `./build` and run config+generate+build, all you need to do is add the `--clean` option, i.e.
```
dbt-build --clean
```
One case where you'd want to do this is if you changed the installation directory variable as described above. 

And if, after the build, you want to run the unit tests, just add the `--unittest` option. Note that it can be used with or without `--clean`, so, e.g.:
```
dbt-build --clean --unittest  # Blow away the contents of ./build, run config+generate+build, and then run the unit tests
```
..where in the above case, you blow away the contents of `./build`,  run config+generate+build, install the result in `$DBT_INSTALL_DIR` and then run the unit tests. Be aware that for many packages, unit tests will only (fully) work if you've also rerun `dbt-workarea-env`. 

To check for deviations from the coding rules described in the [DUNE C++ Style Guide](https://dune-daq-sw.readthedocs.io/en/latest/packages/styleguide/), run with the `--lint` option:
```
dbt-build --lint
```
...though be aware that some guideline violations (e.g., having a function which tries to do unrelated things) can't be picked up by the automated linter. Also note that you can use `dbt-clang-format.sh` in order to automatically fix whitespace issues in your code; type it at the command line without arguments to learn how to use it.

Note that unlike the other options to `dbt-build`, `--lint` and `--unittest` are both capable of taking an optional argument, which is the name of a specific repo in your work area which you'd like to either lint or run unit tests for. This can be useful if you're focusing on developing one of several repos in your work area; e.g. `dbt-build --lint <repo you're working on>`. With `--lint` you can get even more fine grained by passing it the name of a single file in your repository area; either the absolute path for the file or its path relative to the directory you ran `dbt-build` from will work. 

If you want to see verbose output from the compiler, all you need to do is add the `--cpp-verbose` option:
```
dbt-build --cpp-verbose 
```

If you want to change cmake message log level, you can use the `--cmake-msg-lvl` option:
```
dbt-build --cmake-msg-lvl=<ERROR|WARNING|NOTICE|STATUS|VERBOSE|DEBUG|TRACE>
```

You can see all the options listed if you run the script with the `--help` command, i.e.
```
dbt-build --help
```
Finally, note that both the output of your builds and your unit tests are logged to files in the `./log` subdirectory. These files will have ASCII color codes which make them difficult to read with some tools; `less -R <logfilename>`, however, will display the colors and not the codes themselves. 

</details>

## Running

In order to access the applications, libraries and plugins built and installed into the `$DBT_INSTALL_DIR` area during the above procedure, the system needs to be instructed on where to look for them. This is accomplished via tha `env.sh` file you've already seen. E.g., log into a new shell, cd into your work area, then do the following:
```
export DBT_INSTALL_DIR=<your installation directory> # ONLY needed if you didn't use the default
. ./env.sh
```
Note that if you add a new repo to your work area, after building your new code - and hence putting its output in `./build` - you'll need to run `dbt-workarea-env`.

Once the runtime environment is set, just run the application you need. listrev, however, has no applications; it's just a set of DAQ module plugins which get added to CET_PLUGIN_PATH.  


Now that you know how to set up a work area, a classic option for learning about how to run DAQ modules in a work area is [the listrev documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/listrev/).

In the listrev instructions you'll be running a program called `nanorc` to run the DAQ. To learn more about `nanorc` itself, take a look at [the nanorc documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/).


<a name="Finding_Info"></a>
## Finding Info on Your Work Area

A couple of things need to be kept in mind when you're building code in a work area. The first is that when you call `dbt-build`, it will build your repos against a specific release of the DUNE DAQ software stack - namely, the release you (or someone else) provided to `dbt-create` when the work area was first created. Another is that the layout and behavior of a work area is a function of the version of daq-buildtools which was used to create it. As a work area ages it becomes increasingly likely that a problem will occur when you try to build a repo in it; this is natural and unavoidable. 

As such, it's important to know the assumptions a work area makes when you use it to build code. In the base of your work area is a file called `dbt-workarea-constants.sh`, which will look something like the following:
```
export SPACK_RELEASE="fddaq-v4.1.0"
export SPACK_RELEASES_DIR="/cvmfs/dunedaq.opensciencegrid.org/spack/releases"
export DBT_ROOT_WHEN_CREATED="/cvmfs/dunedaq.opensciencegrid.org/tools/dbt/v7.2.1"                         
export LOCAL_SPACK_DIR="/home/jcfree/daqbuild_fddaq-v4.1.0/.spack"
```
This file is sourced whenever you run `dbt-workarea-env`, and it tells both the build system and the developer where they can find crucial information about the work areas' builds. Specifically, these environment variables mean the following:

* `$SPACK_RELEASE`: this is the release of the DUNE DAQ software stack against which repos will build (e.g. `fddaq-v4.1.0`, `NFD23-07-15`, etc.)

* `$SPACK_RELEASES_DIR`: The base of the directory containing the DUNE DAQ software installations. 

* `DBT_ROOT_WHEN_CREATED`: The directory containing the `env.sh` file which was sourced before this work area was first created

* `LOCAL_SPACK_DIR`: If the `-s/--spack` was passed to `dbt-create` when the work area was built, this points to where the local Spack area is located

There are also useful Spack commands which can be executed to learn about the versions of the individual packages you're working with, once you've run `dbt-workarea-env` or `dbt-setup-release`. An [excellent Spack tutorial](https://spack-tutorial.readthedocs.io/en/latest/tutorial_basics.html) inside the official Spack documentation is worth a look, but a few Spack commands can be used right away to learn more about your environment:

* `spack find --loaded -N | grep dunedaq-vX.Y.Z` will tell you all the DUNE DAQ packages common to both far- and near detector software which have been loaded by `dbt-workarea-env` or `dbt-setup-release`

* `spack find --loaded -N | grep fddaq-vX.Y.Z` for far detector DUNE DAQ packages

* `spack find --loaded -N | grep nddaq-vX.Y.Z` for near detector DUNE DAQ packages

* `spack find --loaded -N | grep dunedaq-externals` for external packages not developed by DUNE collaborators

* `spack find --loaded -p <package name>` will tell you the path to the actual contents of a Spack-installed package

Finally, when `dbt-build` is run, a file called `daq_app_rte.sh` is
produced and placed in your installation area (`$DBT_INSTALL_DIR`). You generally don't need to think about `daq_app_rte.sh` unless you're curious; it's a sourceable file which contains environment variables that [nanorc](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/) uses to launch processes when performing runs. 

## Next Step


* You can learn how to create a new package by taking a look at the [daq-cmake documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-cmake/)



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Sat Jul 15 12:07:32 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-buildtools/issues](https://github.com/DUNE-DAQ/daq-buildtools/issues)_
</font>
