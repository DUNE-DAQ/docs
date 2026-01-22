# DAQ Asset Tools

## Overview

DAQ asset files are stored under a 3-level hashed directory in `/cvmfs/dunedaq.opensciencegrid.org/assets/files`. Each asset file has an associated json file with its metadata under the same directory.

There is a SQLite database file (`dunedaq-asset-db.sqlite`) under `/cvmfs/dunedaq.opensciencegrid.org/assets`. Metadata of the files are also stored in this database file.

This repository contains a set of tools to manage these DAQ asset files, available [once the standard DUNE DAQ environment has been set up](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/).

- `assets-list`: list asset files
- `assets-add`: adding new asset files to the catalog
- `assets-update`: update asset files' metadata
- `assets-retire`: retire asset files

Each command has a `-h` option which will tell you how to use it in detail; some of the highlights are covered in this document. 

Files which are part of our assets are catalogued in this [spreadsheet](https://docs.google.com/spreadsheets/d/1oDYe1eEqJhkY0DTd6mfpLw9ou7TqBCaDEgTo0qqVmqY/edit#gid=0), where they provide info to users about each asset. When developers and testers want a new asset, they should open an issue in this repository and select the "Request to add a DAQ asset file" form. The Software Coordination team will then publish the file to `cvmfs`. 

Note that asset files shouldn't exceed more than a couple hundred MB in size; cvmfs responds badly to files larger than that.

## How to see which asset files are available

`assets-list` is the tool for this. It's a flexible tool; see `assets-list -h` for all available options. Here are some examples:

- `assets-list --subsystem readout`
- `assets-list --subsystem readout --copy-to ./`: list files of `readout` subsystem, and copy them to the current directory. The copied file will be renamed as `file-<short_checksum>.ext`, assuming its original file name is `file.ext` 
- `assets-list -c dc74fe934cfb603d74ab6e54a0af7980`: list single file matching the MD5 file checksum
- `assets-list -c dc74fe934cfb603d74ab6e54a0af7980 --copy-to ./`: list single file matching the MD5 file checksum and copy the file to the current directory
- `assets-list --subsystem readout --format binary --status valid --print-metadata`

## How to add, update, and retire asset files

_Note: these operations require write permissions to the database file, and file storage directories. Only Software Coordination team members need to perform these operations._

### `assets-add`

`assets-add` should be used when cataloging a new file. The tool will first check if the database file exists, and create it if not. It will copy the file over to the calculated hashed directory, and produce an associated JSON metadata file.

The tool can take metadata fields from command line as well as from a JSON file. If both are presented, command-line entries take the precedence.

Examples:

- `assets-add -s ./frames1234.bin --db-file ./dunedaq-asset-db.sqlite -n frames1234.bin -f binary --status valid --subsystem readout --label WIBEth --description "Used for FE emulation in FakeCardReader"`

### `assets-update`

Use `assets-update` to update certain metadata fields of a file. Similar as other tools, it takes the metadata fields from command-line for matching files in the database. Additionally, it takes a JSON string from command-line for the new metadata.

Examples:

- `assets-update --subsystem readout --label WIBEth --json-string '{"description": "Used for FE emulation in FakeCardReader during Integration Week."}'`
- `assets-update -c dc74fe934cfb603d74ab6e54a0af7980 --json-string '{"status": "valid"}'`

### `assets-retire`

`assets-retire` is the tool to retire a file. The operation is as simple as change its metadata field 'status' to 'expired'. It will not delete the file itself.

Examples:

- `assets-retire -c dc74fe934cfb603d74ab6e54a0af7980`

### Publishing changes to cvmfs

Publishing changes to cvmfs can be done via the following steps:



1. Prepare changes in a local copy of the cvmfs repository's `assets` directory


2. On a cvmfs publisher node, open a cvmfs transaction, sync the `assets` directory in the repo to the local mirror with new changes, and publish the changes.

The following code snippet shows a real-case example of adding a new file to the database, and "retire" a previous file. For space/logistical reasons it doesn't show that (1) the file also gets logged in the spreadsheet and (2) a DUNE DAQ environment has already been set up. 

#### Prepare changes in a local "assets" mirror

```bash

# Create a local mirror of "assets"

rsync -vlprt /cvmfs/dunedaq.opensciencegrid.org/assets .

# Make changes to the local assets mirror
# Specify the db file path with `--db-file` option so that the changes goes to the local mirror;

## Adding a new file

cd ./assets

# Note that the name, label and description here are just given as examples
assets-add -s <name of file to add as asset> --db-file ./dunedaq-asset-db.sqlite -n wib_link_67.bin -f binary --status valid --subsystem readout --label WIBEth --description "Other WIBEth files have outdated detector_id fields in DAQEthHeader"

## Retiring a file, referring to it by its hash

assets-retire --db-file ./dunedaq-asset-db.sqlite -c a0ddae8343e82ba1a3668c5aea20f3d2

## More low-level: accomplishing the same as above, but via the assets-update command

assets-update --db-file ./dunedaq-asset-db.sqlite -c a0ddae8343e82ba1a3668c5aea20f3d2 --json-string '{"status": "expired"}'

```

#### Publish changes to cvmfs

Technical details of how to publish to cvmfs [is covered in the daq-release documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-release/publish_to_cvmfs/#the-basics). Here, after modifying your local mirror of `assets`, you'd sync it to /cvmfs/dunedaq.opensciencegrid.org/assets:

```bash
rsync -vlprt <user@node_with_local_assets_mirror>:<path_to_local_assets_mirror> /cvmfs/dunedaq.opensciencegrid.org
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Mon Oct 13 21:21:07 2025 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-assettools/issues](https://github.com/DUNE-DAQ/daq-assettools/issues)_
</font>
