# DAQ Asset Tools

DAQ asset files are stored under a 3-level hashed directory in `/cvmfs/dunedaq.opensciencegrid.org/assets/files`. Each asset file has an associated json file with its metadata under the same directory.

There is a SQLite database file (`dunedaq-asset-db.sqlite`) under `/cvmfs/dunedaq.opensciencegrid.org/assets`. Metadata of the files are also stored in this database file.

This repository contains a set of tools to manage these DAQ asset files. 

- `assets-list`: list asset files;
- `assets-add`: adding new asset files to the catalog;
- `assets-update`: update asset files' metadata;
- `assets-retire`: retire asset files.

Files listed in this [spreadsheet](https://docs.google.com/spreadsheets/d/1oDYe1eEqJhkY0DTd6mfpLw9ou7TqBCaDEgTo0qqVmqY/edit#gid=0) are being cataloged. When adding new files, please add new entries to the spreadsheet and let Software Coordination team to catalog and publish the files.

### Installation

`pip install git+https://github.com/DUNE-DAQ/daq-assettools@v1.10.0#egg=daq-assettools # Change the version to the desired version.`

## How to get path to asset files

`assets-list` is the tool for getting the path to asset files. 

Examples:

- `assets-list --subsystem readout`
- `assets-list --subsystem readout --copy-to ./`: list files of `readout` subsystem, and copy them to the current directory. The copied file will be renamed as `file-<short_checksum>.ext`, assuming its original file name is `file.ext`; 
- `assets-list -c dc74fe934cfb603d74ab6e54a0af7980`: list single file matching the MD5 file checksum;
- `assets-list -c dc74fe934cfb603d74ab6e54a0af7980 --copy-to ./`: list single file matching the MD5 file checksum and copy the file to the current directory;
- `assets-list -c dc74fe934cfb603d74ab6e54a0af7980 | tail -n +2| awk '{print $NF}'`: get the file path only;
- `assets-list --subsystem readout --format binary --status valid --print-metadata`

```
usage: assets-list [-h] [--db-file DB_FILE] [-n NAME]
                   [--subsystem {readout,trigger}] [-l LABEL]
                   [-f {binary,text}]
                   [--status {valid,expired,new_version_available}]
                   [--description DESCRIPTION] [--replica-uri REPLICA_URI]
                   [-p] [--copy-to COPY_TO]

optional arguments:
  -h, --help            show this help message and exit
  --db-file DB_FILE     path to database file (default:
                        /cvmfs/dunedaq.opensciencegrid.org/assets/dunedaq-
                        asset-db.sqlite)
  -n NAME, --name NAME  asset name (default: None)
  --subsystem {readout,trigger}
                        asset subsystem (default: None)
  -l LABEL, --label LABEL
                        asset label (default: None)
  -f {binary,text}, --format {binary,text}
                        asset file format (default: None)
  --status {valid,expired,new_version_available}
                        asset file status (default: None)
  -c CHECKSUM, --checksum CHECKSUM
                        MD5 checksum of asset file (default: None)
  --description DESCRIPTION
                        description of asset file (default: None)
  --replica-uri REPLICA_URI
                        replica URI (default: None)
  -p, --print-metadata  print full metadata (default: False)
  --copy-to COPY_TO     path to the directory where asset files will be copied to. (default: None)

```

## How to add, update, and retire asset files

Note: these operations require write permissions to the database file, and file storage directories. Only Software Coordination team members need to perform these operations.

### `assets-add`

`assets-add` should be used when cataloging a new file. The tool will first check if the database file exists, and create it if not. It will copy the file over to the calculated hashed directory, and produce an associated JSON metadata file.

The tool can take metadata fields from command line as well as from a JSON file. If both are presented, command-line entries take the precedence.

Examples:

- `assets-add -s ./frames.bin --db-file ./dunedaq-asset-db.sqlite -n frames.bin -f binary --status valid --subsystem readout --label ProtoWIB --description "Used for FE emulation in FakeCardReader"`

```
usage: assets-add [-h] [--db-file DB_FILE] [-n NAME]
                  [--subsystem {readout,trigger}] [-l LABEL]
                  [-f {binary,text}]
                  [--status {valid,expired,new_version_available}]
                  [--description DESCRIPTION] [--replica-uri REPLICA_URI]
                  [-s SOURCE] [--json-file JSON_FILE]

optional arguments:
  -h, --help            show this help message and exit
  --db-file DB_FILE     path to database file (default:
                        /cvmfs/dunedaq.opensciencegrid.org/assets/dunedaq-
                        asset-db.sqlite)
  -n NAME, --name NAME  asset name (default: None)
  --subsystem {readout,trigger}
                        asset subsystem (default: None)
  -l LABEL, --label LABEL
                        asset label (default: None)
  -f {binary,text}, --format {binary,text}
                        asset file format (default: None)
  --status {valid,expired,new_version_available}
                        asset file status (default: None)
  -c CHECKSUM, --checksum CHECKSUM
                        MD5 checksum of asset file (default: None)
  --description DESCRIPTION
                        description of asset file (default: None)
  --replica-uri REPLICA_URI
                        replica URI (default: None)
  -s SOURCE, --source SOURCE
                        path to asset file (default: None)
  --json-file JSON_FILE
                        json file containing file metadata (default: None)

```

### `assets-update`

Use `assets-update` to update certain metadata fields of a file. Similar as other tools, it takes the metadata fields from command-line for matching files in the database. Additionally, it takes a JSON string from command-line for the new metadata.

Examples:

- `assets-update --subsystem readout --label ProtoWIB --json-string '{"description": "Used for FE emulation in FakeCardReader during Integration Week."}'`
- `assets-update -c dc74fe934cfb603d74ab6e54a0af7980 --json-string '{"status": "valid"}'`

```
usage: assets-update [-h] [--db-file DB_FILE] [-n NAME]
                     [--subsystem {readout,trigger}] [-l LABEL]
                     [-f {binary,text}]
                     [--status {valid,expired,new_version_available}]
                     [--description DESCRIPTION] [--replica-uri REPLICA_URI]
                     [--json-string JSON_STRING]

optional arguments:
  -h, --help            show this help message and exit
  --db-file DB_FILE     path to database file (default:
                        /cvmfs/dunedaq.opensciencegrid.org/assets/dunedaq-
                        asset-db.sqlite)
  -n NAME, --name NAME  asset name (default: None)
  --subsystem {readout,trigger}
                        asset subsystem (default: None)
  -l LABEL, --label LABEL
                        asset label (default: None)
  -f {binary,text}, --format {binary,text}
                        asset file format (default: None)
  --status {valid,expired,new_version_available}
                        asset file status (default: None)
  -c CHECKSUM, --checksum CHECKSUM
                        MD5 checksum of asset file (default: None)
  --description DESCRIPTION
                        description of asset file (default: None)
  --replica-uri REPLICA_URI
                        replica URI (default: None)
  --json-string JSON_STRING
                        json string to be updated in metadata (default: None)
```

### `assets-retire`

`assets-retire` is the tool to retire a file. The operation is as simple as change its metadata field 'status' to 'expired'. It will not delete the file itself.

Examples:

- `assets-retire -c dc74fe934cfb603d74ab6e54a0af7980`

```
usage: assets-retire [-h] [--db-file DB_FILE] [-n NAME]
                     [--subsystem {readout,trigger}] [-l LABEL]
                     [-f {binary,text}]
                     [--status {valid,expired,new_version_available}]
                     [-c CHECKSUM] [--description DESCRIPTION]
                     [--replica-uri REPLICA_URI]

optional arguments:
  -h, --help            show this help message and exit
  --db-file DB_FILE     path to database file (default:
                        /cvmfs/dunedaq.opensciencegrid.org/assets/dunedaq-
                        asset-db.sqlite)
  -n NAME, --name NAME  asset name (default: None)
  --subsystem {readout,trigger}
                        asset subsystem (default: None)
  -l LABEL, --label LABEL
                        asset label (default: None)
  -f {binary,text}, --format {binary,text}
                        asset file format (default: None)
  --status {valid,expired,new_version_available}
                        asset file status (default: None)
  -c CHECKSUM, --checksum CHECKSUM
                        MD5 checksum of asset file (default: None)
  --description DESCRIPTION
                        description of asset file (default: None)
  --replica-uri REPLICA_URI
                        replica URI (default: None)
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Pengfei Ding_

_Date: Tue Feb 14 11:35:00 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-assettools/issues](https://github.com/DUNE-DAQ/daq-assettools/issues)_
</font>
