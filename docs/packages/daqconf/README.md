#  Configuration creation, visualization and manipulation
This repository contains scripts for generating and manipulating OKS database files.

## Visualization tools

### `daqconf_inspector`

Commandline utility to visually inspect and verify configurations databases and the objects they contain. Documenation available
[here](Inspector.md).

### `create_config_plot`

Commandline utility to generate a graphical flow diagram of a full configuration session or one of its applications or segments. Documentation available [here](ConfigPlotting.md).

## Manipulation Tools

### `oks_enable`
  Add Resource objects to or remove from the `disabled` relationship of a Session

### `consolidate`
  Merge the contents of several database files, putting all objects into a single output file. Output file will only include schemas.

### `consolidate_files`
  Merge the contents of several database files, preserving included databases. Output file will contain only objects defined in files given on command line.

### `copy_configuration`
  Copy the input file(s) to the specified directory, also moving any included files and updating include paths, to create a clone of the configuration databases.

### `get_apps`
  Retrieve the DAQ applications defined in the given configuration

### `oks-format`
  Ensure that database files are in the "DBE format", alphabetized and with correct spacing

### `oks_enable_tpg`
  Enable or disable TPG for a Session's ReadoutApplications

### `validate`
  Attempt to determine if a given Session configuration is valid and does not contain common errors


### textual_dbe
 Attempt to replicate OKS' Data Base editor within Python. Full details are [here](TextualDBE.md). Current implementation is very incomplete so use with caution.

## Generation Tools

### `createOKSdb`
   A script that generates an 'empty' OKS database, just containging
the include files for the core schema and any other schema/data files
you specify on the commad line.

### `dromap2oks`
  Convert a JSON readout map file from dunedaq v4 to an OKS file.

### `generate_readoutOKS`

  Create an OKS configuration file defining ReadoutApplications for
  all readout groups defined in a readout map.

## Additional Python Utilities

### `assets.py`
  Read the DUNE-DAQ asset file database and return a path to a referenced asset file

### `generate.py`
  A collection of methods to generate segments and sessions.

###` generate_hwmap.py`
  Create a set of DetectorToDaqConnection objects, GeoIDs, and streams for the given number of links and applications.

### `utils.py`
  Utilities for parsing OKS databases. Currently contains an include file search routine.



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu Oct 24 09:14:29 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
