# SNBmodules

Doxygen's generation (with docs/Doxyfile the doxygen configuration file in snbmodules) :
```
doxygen docs/Doxyfile
```

Here is an example design choice for the Supernova Burst dataflow (SNB). In this context, 150 TB of data over 100 seconds of recording will be in the underground. How to chip them out under the different SNB dataflow challenges ?

<p align="center"><img width="700" alt="SNB Sataflow design graph" src="https://github.com/DUNE-DAQ/snbmodules/assets/31961987/4f24e6bb-6b6a-4cd7-a396-ae017018dc94"></p>

# Requirements 
to respect timings of the different scenario of the data taking mode :

* Speed and scalability

* Fully controllable transfers

* Get transfer information

* Modularity, can use multiple transfer implementation

Transfer requirements

* Pause / Resume

* Performance

* Rate limited

* Data integrity checking

* Many to One

# Design of SNBmodules

![SNBmodules - Class Diagram simplified V2](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/1fa7cc24-bf52-4e64-ac41-356b65b51d79)


## My Design choices

* Client started on each node can create

  * Downloader Session (to receive files)

  * Uploader Session (to send files)

* Bookkeeper

  * Visual interface

  * Track files transfer metadata

    * File full path

    * Hash

    * Bytes size

    * Bytes transfered

    * Actual Transmission speed

    * Status

      * PREPARING

      * ERROR

      * SUCCESS_UPLOAD

      * SUCCESS_DOWNLOAD

      * FINISHED

      * CANCELLED

      * PAUSED

      * WAITING

      * CHECKING

      * HASHING

      * UPLOADING

      * DOWNLOADING

    * Source client

    * Destination client

    * Error code if any

    * Start time of transfer

    * End time of transfer

    * Duration of transfer (useful if ongoing)

    * Group transfer ID

* Uploaders Clients control and initiate transfers that can be on any implemented protocol

  * dummy (debug purposes)

  * SCP (testing purposes)

  * BITTORRENT

  * RCLONE


* Can be modified !

SNBmodules - Client Use Case diagram             |  SNBmodules - Bookkeeper Use Case diagram
:-------------------------:|:-------------------------:
![client_use_case](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/3f27e6f5-e68e-4c2f-bb80-b73d5a6a4568)  |  ![bookkeeper_use_case](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/04dca9c0-f687-4e49-8bc1-24117e64c898)


## Activity Diagrams
![initiate_connection](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/7d93428b-1bcf-4c1b-a84f-fb0cd94091c8)
![Start Transfer](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/70bd0fca-9b26-4c32-a0ba-9e03d57ee421)
![pause-transfer](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/62188ab8-2c83-4831-b175-9aa30f2488e3)
![update-meta](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/7f218dbc-c201-4e92-b6d1-634fe6cb505e)


# Implementation
<img width="500" align="right" alt="SNBmodules - General Communication" src="https://github.com/DUNE-DAQ/snbmodules/assets/31961987/de277347-2929-44ae-9bdd-d3775d0b211f">


* Notification system

  * Using Connectivity Service library (IOManager)

  * Use wrapper interface : interchangeability

* Transfer Interface

  * Fully modular

  * Choice of transfer protocol libraries matures to respect requirements

    * Already existing libraries : unify them in my solution

    * Fast and multi-connection support

    * SCP (for test purposes), one to one

    * LibTorrent : BitTorrent peer to peer protocol

    * RClone : HTTP protocol, one to one with multiple connections

  * Parameters parsed on transmission

* Control aspects

  * Expert Commands send to Uploader client

  * Graphic Interface

# Integration

## Integration tests

daqconf modifications available in [ljoly/snbmodules-config branch in daqconf](https://github.com/DUNE-DAQ/daqconf/tree/ljoly/snbmodules-config)


* snbmodules_gen.py

* snbmodulesgen.jsonnet

Implemented integration tests

Run with
```
pytest -s 'test_name.py'
```


* snbmodules/integtest/snb_1node_1app_system_quick_test.py : one full Node with readout and raw recording activated. Here, one snbmodules application start multiple clients on the same host. Useful for tests purposes. 

* snbmodules/integtest/snb_1node_multiapp_system_quick_test.py : Same as before, but all clients are started in a different nanorc application.

The integration tests uses python check scripts and commands :

* Using raw_file_check.py utility functions to test integrity of RAW binary files transferred locally

* Using transfer_check.py utility functions to test errors and check transfers in the Bookkeeper log file

* record-cmd.json : Expert command asking the readout application to record during 1 second

* new-RClone-transfer.json : Initiate a new transfer using RClone protocol (SFTP for test purposes, but can be changed : careful BitTorrent only support transfer to different IP addresses). The list of files and destination clients is automatically filled up by the integration tests.

* start-transfer.json : Simply send the start transfer command.

## Systems tests for multi node testing

Available in [daq-systemtest](https://github.com/DUNE-DAQ/daq-systemtest/tree/ljoly/snbmodules_systems_tests/config/snbmodules_systems)
Different configuration files with different setup.
The standard idea is that each host have one client startup and the bookkeeper is started somewhere else. You can refer to the scale configuration [large_scale_system_with_snbmodules.json](https://github.com/DUNE-DAQ/daq-systemtest/blob/ljoly/snbmodules_systems_tests/config/scale_tests/large_scale_system_with_snbmodules.json) to see a standard configuration.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Leo Joly_

_Date: Tue Sep 26 13:16:18 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
