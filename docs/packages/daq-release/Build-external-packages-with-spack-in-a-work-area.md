# Build external packages with spack in a work area
Developers occasionally need to utilize a different variant, a new version, or a completely new external package before its inclusion and deployment in the DUNE DAQ external software stack on CVMFS. Here's a step-by-step guide on how to do this:



1. Create a work area using the `-s` flag with the `dbt-create` command. This will generate a `.spack` subdirectory within the work area, with the external stack and release stack as upstreams to it.


2. For the external package, either copy or create the desired Spack recipe file and place it in the directory:
`<workarea>/.spack/spack-repo/packages/<package_name>/package.py`. Detailed instructions on creating this recipe file are provided below.


3. Run the `spack install` command, for example `spack install <package>@version%gcc@12.1.0 arch=linux-almalinux9-x86_64`. Of course, know what spec you want.


4. After installation, load the newly installed Spack package and run `dbt-build` to build your DUNE DAQ packages. If `dbt-build` complains about `dbt-workarea-env` not being run, reload the Python virtual environment as follows:
```bash
deactivate
source .venv/bin/activate
```

## Spack recipe files for the new external packages

### New external package

For a new external package, there may already be a recipe file in Spack's built-in repository. To check for available versions and their dependencies, use the following command:
```bash
spack info <package_name>
```
You can also open the recipe file in your default editor with:
```bash
spack edit <package_name>
```
If no recipe file exists, consider reaching out to Software Coordination for assistance in creating one.

### Existing external package

For existing external packages, you can copy the recipe file (and related patches) from either the built-in Spack repository or daq-release/spack-repo/externals. Copy the entire directory from the source path to your work area's Spack repository path:
```bash
cp -pr <spack-repo-path>/packages/<package_name> <workarea>/.spack/spack-repo/packages/<package_name>
```
This ensures you copy both the recipe file and related patch files.

### Adding a new version

If a recipe file exists but lacks entries for newer versions, use the following command to have Spack check for available versions and generate checksums:

```bash
spack checksum <package_name>
```

Copy the output for the new versions and their associated checksums into the recipe file to make these versions available. Additionally, check if the package uses patches when building. If patches are in use, confirm if existing patches are still applicable; otherwise, create new ones. Contact Software Coordination for assistance as needed.

## Example: Building and Using a New `HighFive` version in a work area

```bash
## Creating a work area with the "-s" option of "dot-create"
source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh
setup_dbt latest
dbt-create -s -n NFD_PROD4_240404_A9 daqbuild_NFD_PROD4_240404_A9
cd daqbuild_NFD_PROD4_240404_A9

## Obtaining the Spack recipe file and placing it into the local Spack repository
git clone https://github.com/DUNE-DAQ/daq-release
cp -pr daq-release/spack-repos/externals/packages/highfive .spack/spack-repo/packages/

## Setting up Spack and building the HighFive using RelWithDebInfo rather than the already-installed build_type=Release
dbt-workarea-env
spack install --reuse highfive@2.7.1%gcc@12.1.0~boost~ipo+mpi build_system=cmake build_type=RelWithDebInfo

spack find -p -l highfive  # Use this to find the Spack hash for the highfive you just built
spack load <hash>          # And load it in

## Reloading the Python virtual environment
## "spack load" sometimes modifies PYTHONPATH, which could cause issues with "dbt-build."
## Reloading the environment before running "dbt-build" avoids this potential issue.
deactivate
source .venv/bin/activate

# JCF, Apr-04-2024: unclear if the following is still relevant/correct...

## Building the DAQ package using features available only in the locally installed HighFive
cd sourcecode/
git clone https://github.com/DUNE-DAQ/hdf5libs -b leo-update-tests-apps
# Modify hdf5libs's CMakeLists.txt to set:
# option(WITH_HIGHFIVE_AS_PACKAGE "HIGHFIVE externals as a dunedaq package" ON)
# option(WITH_HDF5_AS_PACKAGE "HDF5 externals as a dunedaq package" ON)

dbt-build
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu Apr 4 08:51:18 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-release/issues](https://github.com/DUNE-DAQ/daq-release/issues)_
</font>
