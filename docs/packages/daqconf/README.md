# daqconf

This repository contains tools for generating DAQ system common configurations, the [`fddaqconf_gen` script](https://github.com/DUNE-DAQ/fddaqconf/blob/develop/scripts/fddaqconf_gen) ("DAQ configuration, multiple readout unit generator"). It generates DAQ system configurations with different characteristics based on the configuration file and command-line parameters given to it. 

The focus of this documentation is on providing instructions for using the tools and running sample DAQ systems. If you're starting out, take a look at:

[Instructions for casual or first-time users](InstructionsForCasualUsers.md)

For a slightly more in-depth look into how to generate configurations for a DAQ system, take a look at:

[Configuration options for casual or first-time users](ConfigurationsForCasualUsers.md)

If you want to view existing configs stored in the MongoDB, or run configurations accessible through the run-registry microservice, take a look at:

[Interacting with the Configuration Database](ConfigDatabase.md)

Finally, here's nice visual representation of the type of DAQ system which can be configured: 

<img width="697" alt="v3 0 0_screenshot_08Jun2022" src="https://user-images.githubusercontent.com/36311946/172657352-20db6334-13b6-4dd5-9e99-ef989ad6a4af.png">



## Some details of the configurations

### Pattern file

The "pattern" file, which is used to emulate the readout system is provided by the `data_files` entry of the `readout` part of the configuration.

This has the form of a list, for example:
```json
{
    "readout": {
        "data_files": [
            { "detector_id": 2,  "data_file": "asset://?label=ProtoWIB&subsystem=readout" },
            { "detector_id": 3,  "data_file": "asset://?checksum=9f14e12a0ebdaf207e9e740044b2433c" },
            { "detector_id": 4,  "data_file": "./frames.bin" },
            { "detector_id": 5,  "data_file": "file:///some/path/note/the/3/slashes/at/the/beginning/frames.bin"},
            { "detector_id": 11, "data_file": "" }
        ]
        ...
    }
    ...
}
```

In this configuration the `detector_id` is used to key the pattern file. This `detector_id` is the same as the one in your hardware map file (5th column). So if you provide the wrong file with a for a `detector_id` in your configuration, the readout will most likely issue error because the fragments are not decoded correctly. Similarly, if a you have `detector_id` in your hardware map that is not in the `data_files` list, the default is a "ProtoWIB" emulator file.


For `data_file`, you can specify:


| location desired | syntax                   | example                                                                |
| ---------------- | ------------------------ | ---------------------------------------------------------------------- |
| file system      | `<absolute-path>`        | `/some/path/frames.bin`                                                |
| file system      | `file://<absolute-path>` | `file:///some/path/note/the/THREE/slashes/at/the/beginning/frames.bin` |
| file system      | `file://<relative-path>` | `file://some/path/note/the/TWO/slashes/at/the/beginning/frames.bin`    |
| file system      | `<relative path>`        | `../some/path/frames.bin`                                              |
| asset            | `asset://?query`         | `asset://?label=ProtoWIB&subsystem=readout`                            |


The query should be of the form:
```
field1=value1&field2=value2
```

Right now, the all the assets are:
```bash
> assets-list --subsystem readout
checksum                         subsystem       label           status          file_path
dc74fe934cfb603d74ab6e54a0af7980 readout         DuneWIB         valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/d/c/7/np04_hd_run017745_sample_wib2.bin
9f14e12a0ebdaf207e9e740044b2433c readout         ProtoWIB        valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/9/f/1/frames.bin
0c9ed91bbda14d9baa170e4138d56fcd readout         DuneWIB         expired         /cvmfs/dunedaq.opensciencegrid.org/assets/files/0/c/9/wib2-frames.bin
c1410bf267da088153c41c3471e7f98e readout         WIBEth          valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/c/1/4/wibeth-frames-0.bin
c559c652ec47183204607ac435ca7c4b readout         WIBEth          valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/c/5/5/wibeth-frames-1.bin
18c60e85543a9a2c2c79f74753837e1c readout         WIBEth          valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/1/8/c/wibeth-frames-2.bin
4c7b48faa61147c78db986ef11c91b26 readout         WIBEth          valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/4/c/7/wibeth-frames-3.bin
e2f7a4d6ae354c2d6529c190ec8335f3 readout         DuneWIB         valid           /cvmfs/dunedaq.opensciencegrid.org/assets/files/e/2/f/wib2-frames.bin
```

and there are no asset files in the "trigger" subsystem.

Note that daqconf will _not_ use an expired asset.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Mon Sep 25 11:03:00 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
