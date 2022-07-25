
_n.b. While not recommended, if you want to build your repo area against UPS packages rather than Spack packages, instructions are at [the bottom of this document](#ups_instructions)_

# DUNE DAQ Buildtools

`daq-buildtools` is the toolset to simplify the development of DUNE DAQ packages. It provides environment and building utilities for the DAQ Suite.

## System requirements

To get set up, you'll need access to the cvmfs Spack area
`/cvmfs/dunedaq-development.opensciencegrid.org/spack-nightly` as is
the case, e.g., on the lxplus machines at CERN. If you've been doing
your own Spack work on the system in question, you may also want to
back up (rename) your existing `~/.spack` directory to give Spack a
clean slate to start from in these instructions.

You'll also want `python` to be version 3; to find out whether this is the case, run `python --version`. If it isn't, then you can switch over to Python 3 with the following simple commands:
```
source `realpath /cvmfs/dunedaq.opensciencegrid.org/spack-externals/spack-installation/share/spack/setup-env.sh`
spack load python@3.8.3%gcc@8.2.0
```

<a name="Setup_of_daq-buildtools"></a>
## Setup of `daq-buildtools`

In a directory which doesn't contain a daq-buildtools repository, simply do:

```
source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh
setup_dbt latest-spack
```

Then you'll see something like:
```
Added /tmp/daq-buildtools/bin -> PATH
Added /tmp/daq-buildtools/scripts -> PATH
DBT setuptools loaded
```
If you type `dbt-` followed by the `<tab>` key you'll see a listing of available commands, which include `dbt-create`, `dbt-build`, `dbt-setup-release` and `dbt-workarea-env`. These are all described in the following sections. 

Each time that you want to work with a DUNE DAQ work area in a fresh Linux shell, you'll need to set up daq-buildtools, either by repeating the method above, or by `cd`'ing into your work area and sourcing the link file named `dbt-env.sh`. Work areas are described momentarily. 

<a name="Running_a_release_from_cvmfs"></a>
## Running a release from cvmfs

Running a release from cvmfs without creating a work area can be done if you simply run the following:

```sh
dbt-setup-release <release> # dunedaq-v3.1.0 is the latest release as of Jul-25-2022
```
Instead of a frozen release you can also set up nightly releases and candidate releases using the same arguments as are described later for `dbt-create`; e.g. if you want to set up a candidate release you can do:
```
dbt-setup-release -b candidate <candidate release> # rc-dunedaq-v3.1.0-1 is the latest candidate release as of Jul-18-2022
```

`dbt-setup-release` will set up both the external packages and DAQ packages, as well as activate the python virtual environment. Note that the python virtual environment activated here is read-only. You'd want to run `dbt-setup-release` only if you weren't developing DUNE DAQ software, the topic covered for the remainder of this document. However, if you don't want a frozen set of versioned packages - which you wouldn't, if you were developing code - please continue reading.


<a name="Creating_a_work_area"></a>
## Creating a work area

Find a directory in which you want your work area to be a subdirectory (home directories are a popular choice) and `cd` into that directory. Then think of a good name for the work area (give it any name, but we'll refer to it as "MyTopDir" on this wiki). If you want to build against the nightly release (i.e., the official DUNE DAQ package installation which updates every night), run:
```sh
dbt-create [-c/--clone-pyvenv] -n <nightly release> <name of work area subdirectory> # E.g., N22-04-18 or last_successful
cd <name of work area subdirectory>
```

If you want to build against a candidate release (which is built and deployed during the beta testing period of a release cycle), run:
```sh
dbt-create [-c/--clone-pyvenv] -b candidate <candidate release> <name of work area subdirectory> # E.g., rc-dunedaq-v3.0.0-1 as of May-23-2022.
cd <name of work area subdirectory>
```

To see all available nightly releases, run `dbt-create -l -n` or `dbt-create -l -b nightly`. To see all available candidate releases, run `dbt-create -l -b candidate`. Less common but also possible is to build your repos not against a nightly release but against a frozen release; the commands you pass to `dbt-create` are the same, but with the `-n` or `-b <option>` dropped. 

The option `-c/--clone-pyvenv` for `dbt-create` is optional. If used, the python virtual environment created in the work area will be a clone of an existing one from the release directory. This avoids the compilation/installation of python modules using the `pyvenv_requirements.txt` in the release directory, and speeds up the work-area creation significantly. The first time running `dbt-create` with this option on a node may take a longer time since cvmfs needs to fetch these files into local cache first.

The second of the two commands above is important: remember to `cd` into the subdirectory you just created after `dbt-create` finishes running. 

The structure of your work area will look like the following:
```txt
MyTopDir
├── build
├── dbt-pyvenv
├── dbt-env.sh -> /path/to/daq-buildtools/env.sh
├── dbt-workarea-constants.sh
├── log
└── sourcecode
    ├── CMakeLists.txt
    └── dbt-build-order.cmake
```
The next section of this document concerns how to build code in your new work area. However, if you'd like to learn about how to retrieve information about your work area such as the release of the DUNE DAQ suite it builds against, you can skip ahead to [Finding Info on Your Work Area](#Finding_Info).

<a name="Cloning_and_building"></a>
## Cloning and building a package repo

### The basics

For the purposes of instruction, let's build the `listrev` package. Downloading it is simple:
```
cd sourcecode
git clone https://github.com/DUNE-DAQ/listrev.git
cd ..
```

Note that in a "real world" situation [you'd be doing your development on a feature branch](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/development_workflow_gitflow/) in which case you'd add `-b <branch you want to work on>` to the `git clone` command above. 


We're about to build and install the `listrev` package. (&#x1F534; Note: if you are working with other packages, have a look at the [Working with more repos](#working-with-more-repos) subsection before running the following build command.) By default, the scripts will create a subdirectory of MyTopDir called `./install ` and install any packages you build off your repos there. If you wish to install them in another location, you'll want to set the environment variable `DBT_INSTALL_DIR` to the desired installation path before calling the `dbt-workarea-env` command described below. You'll also want to remember to set the variable during subsequent logins to the work area if you don't go with the default. 

Now, do the following:
```sh
dbt-workarea-env  # To set up your work area's environment
dbt-build
```
...and this will build `listrev` in the local `./build` subdirectory and then install it as a package either in the local `./install` subdirectory or in whatever you pointed `DBT_INSTALL_DIR` to. Note that whenever you add a new repo to your work area, you'll want to rerun `dbt-workarea-env` so that environment variables such as `LD_LIBRARY_PATH`, etc, are updated accordingly. 


### Working with more repos

To work with more repos, add them to the `./sourcecode` subdirectory as we did with listrev. Be aware, though: if you're developing a new repo which itself depends on another new repo, daq-buildtools may not already know about this dependency. "New" in this context means "not listed in `/cvmfs/dunedaq.opensciencegrid.org/releases/dunedaq-v3.0.0-c7/dbt-build-order.cmake`". If this is the case, you have one of two options:


* (Recommended) Add the names of your new packages to the `build_order` list found in `./sourcecode/dbt-build-order.cmake`, placing them in the list in the relative order in which you want them to be built. 

* First clone and build your new base repo, and THEN clone and build your other new repo which depends on your new base repo. 

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

In order to access the applications, libraries and plugins built and installed into the `$DBT_INSTALL_DIR` area during the above procedure, the system needs to be instructed on where to look for them. This is accomplished via tha `dbt-workarea-env` command you've already seen. E.g., log into a new shell and set up the daq-buildtools environment as described at the top of this document, cd into your work area, then do the following:
```
export DBT_INSTALL_DIR=<your installation directory> # Only needed if you didn't use the default
dbt-workarea-env
```


Note that if you add a new repo to your work area, after building your new code - and hence putting its output in `./build` - you'll need to run `dbt-workarea-env`.

Once the runtime environment is set, just run the application you need. listrev, however, has no applications; it's just a set of DAQ module plugins which get added to CET_PLUGIN_PATH.  


Now that you know how to set up a work area, a nice place to learn a bit about the DUNE DAQ suite is via the `daqconf` package. Take a look at its documentation [here](https://dune-daq-sw.readthedocs.io/en/latest/packages/daqconf/); note that in parts of the `daqconf` instructions you're told to run daq-buildtools commands which you may already have run (e.g., to create a new work area) in which case you can skip those specific commands.

A classic option for learning about how to run DAQ modules in a work area is [the listrev documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/listrev/).

In both the links above you'll notice you'll be running a program called `nanorc` to run the DAQ. To learn more about `nanorc` itself, take a look at [the nanorc documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/).


<a name="Finding_Info"></a>
## Finding Info on Your Work Area

A couple of things need to be kept in mind when you're building code in a work area. The first is that when you call `dbt-build`, it will build your repos against a specific release of the DUNE DAQ software stack - namely, the release you (or someone else) provided to `dbt-create` when the work area was first created. Another is that the layout and behavior of a work area is a function of the version of daq-buildtools which was used to create it. As a work area ages it becomes increasingly likely that a problem will occur when you try to build a repo in it; this is natural and unavoidable. 

As such, it's important to know the assumptions a work area makes when you use it to build code. In the base of your work area is a file called `dbt-workarea-constants.sh`, which will look something like the following:
```
export SPACK_RELEASE="N22-04-09"
export SPACK_RELEASES_DIR="/cvmfs/dunedaq-development.opensciencegrid.org/spack-nightly"
export DBT_ROOT_WHEN_CREATED="/home/jcfree/daq-buildtools"
```
This file is sourced whenever you run `dbt-workarea-env`, and it tells both the build system and the developer where they can find crucial information about the work areas' builds. Specifically, these environment variables mean the following:

* `$SPACK_RELEASE`: this is the release of the DUNE DAQ software stack against which repos will build (e.g. `dunedaq-v2.10.2`, `N22-04-09`, etc.)

* `$SPACK_RELEASES_DIR`: The base of the directory containing the DUNE DAQ software installations. The directory `$SPACK_RELEASES_DIR/$SPACK_RELEASE` contains the installation of the packages for your release

* `DBT_ROOT_WHEN_CREATED`: The directory containing the `env.sh` file which was sourced before this work area was first created

There are also useful Spack commands which can be executed to learn about the versions of the individual packages you're working with. An [excellent Spack tutorial](https://spack-tutorial.readthedocs.io/en/latest/tutorial_basics.html) inside the official Spack documentation is worth a look, but a few Spack commands can be used right away to learn about a work area:

* `spack find --loaded -N | grep $SPACK_RELEASE` will tell you all the DUNE DAQ packages which have been loaded by `dbt-workarea-env` (or `dbt-setup-release`, for that matter)

* `spack find --loaded -N | grep dunedaq-externals` is the same, but will tell you all the external packages

* `spack find --loaded -p <package name>` will tell you the path to the actual contents of a Spack-installed package


## Next Step


* You can learn how to create a new package by taking a look at the [daq-cmake documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-cmake/)

<a name="ups_instructions"></a>
## UPS Instructions

In order to create a work area which builds against UPS-installed packages rather than Spack-installed packages, you can follow the old [2.11.1 instructions](https://dune-daq-sw.readthedocs.io/en/v2.11.1/packages/daq-buildtools/). On top of those instructions however, you should be aware of two things:


1. Instead of using the `dunedaq-v2.11.1-cs8` and `dunedaq-v2.11.1-c7` releases, you also have `dunedaq-v3.0.0-cs8` and `dunedaq-v3.0.0-c7` releases available.


2. Easier to remember than the `v4.1.7` version label for daq-buildtools described in those instructions is its alias, `legacy-ups`.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Mon Jul 25 13:36:23 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-buildtools/issues](https://github.com/DUNE-DAQ/daq-buildtools/issues)_
</font>
