# Integration tests of SNBmodules

The integration tests of `snbmodules` are located in the integtest folder, and the tests are usually executed under the `snbmodules/integtest/` folder as follows:

```
pytest -s <test_file_name>.py --nanorc-option partition-number 2
```

## Nomenclature


* Bookkeeper : Monitor file transfers status and registers/logs metadata about these transfers

* TransferClient : Client object that contains transfer implenetation (e.g.: torrent, rclone, etc.) sessions (upload, download)

* Transfer metadata : Contains informations about file transfers and their states

* Group metadata : Contains multiple Transfer metadata uploaded by the same transfer client

## snb_minimal_system_test.py

This very simple integration test contains 4 daq_applications (processes), each with a single module, running on a single host.


**App topology**:
| daq_application(s) |          module(s)         |
|:------------------:|:--------------------------:|
|    snbbookkeeper   |  1 x SNBTransferBookkeeper |
|     snbclient0     |     1 x SNBFileTransfer    |
|     snbclient1     |     1 x SNBFileTransfer    |
|     snbclient2     |     1 x SNBFileTransfer    |


**Aim of the test**: Verify that the different SNB file transfer modules respect the state machine, the control interfaces are
working as expected and can be communicated with via the run control. It also ensures that the SNB plugin configuration generators are working 
as expected. This test doesn't test actual transfers! There are individual tests for testing transfer implementations of different protocols.


**Test steps**:


1. Generate default configs for `snbmodules`.


2. Modify `snbmodules` configurations.


3. Add `bookkeeper` to `snbmodules` configuration.


4. Add `client` apps, in this case three.


5. Populate nanorc command list: 

```
nanorc_command_list = "integtest-partition boot conf start 111 wait 1 enable_triggers ".split()
nanorc_command_list += ["wait"] + [str(run_duration)]
nanorc_command_list += "stop_run wait 2 scrap terminate".split()
```


**Pass criteria**:


1. test_nanorc_success: nanorc completed processes return code is 0 (no errors)


2. test_log_files: log files are error free


3. test_local_transfer_snbmodules: snb client process spawned and controlled successfully


4. test_bookkeeper_snbmodules: snb bookkeeper process spawned and controlled succesffully


**Caveats/extra steps needed**: None


**Troubleshooting**: None


## snb_1node_1app_torrent_system_quick_test.py

This simple integration test contains a full system integration, exercising recorded SNB file transfer between different processes, running on a single host.
The test exercises the torrent based file transfer implementation, and the SNB recording within the readout subsystem. The test contains a single SNB client process,
which has both uploader and downloader sessions.


**App topology**:
| daq_application(s) |                                      plugin(s), notes                                     |
|:------------------:|:-----------------------------------------------------------------------------------------:|
|      dataflow0     |                            usual integtest topology and config                            |
|         dfo        |                            usual integtest topology and config                            |
|       fakehsi      |                            usual integtest topology and config                            |
|       trigger      |                            usual integtest topology and config                            |
|   rulocalhosteth0  | usual integtest topology and config  (2 fake/sw based WIBEth producers, raw recording on) |
|    snbbookkeper    |                                 1 x SNBTransferBookkeeper                                 |
|      snbclient     |                   2 x SNBFileTransfer (one uploader and one downloader)                   |


**Aim of the test**: Verify that files can be transferred between processes using the torrent based implementation. For source files, the integtest
uses the readout raw recording features, in order to exercise the file registration ("new file transfer") command of SNBModules (bookkeeper and client).
This also aims to verify the functionality and command sequence between readout and dataflow subsystems. The configuration parameters and aspects of the
torrent based transfer implementation is also demonstrated and tested here.


**Test steps**:


1. Generate default configs for subsystems.


2. Modify `snbmodules` configurations.


3. Add `bookkeeper` to `snbmodules` configuration.


4. Prepare `record-cmd.json` to record raw content for 1 second from every data producers in the `rulocalhosteth0` app.


5. Prepare `new-torrent-transfer.json` expert command for registering a transfer -> source and destination clients and file list. (Protocol arguments: select BITTORRENT and port to be used)


6. Prepare `start-torrent-transfer.json` expert command to start the upload/download procedure for the registered transfers.


7. Populate nanorc command list:

```
# The commands to run in nanorc, as a list
nanorc_command_list="integtest-partition boot conf start 111 wait 1 enable_triggers wait ".split() + [str(run_duration)] + \
("expert_command /json0/json0/ru" + interface_name + f" {root_path_commands}/record-cmd.json ").split() + \
["wait"] + [str(record_duration)] + \
f"expert_command /json0/json0/snbclient {root_path_commands}/new-torrent-transfer.json ".split() + \
f"expert_command /json0/json0/snbclient {root_path_commands}/start-torrent-transfer.json ".split() + \
["wait"] + [str(send_duration)] + "stop_run wait 2 scrap terminate".split()
```


**Pass criteria**:


1. test_nanorc_success: nanorc completed processes return code is 0 (no errors)


2. test_log_files: log files are error free


3. test_data_files: sanity check of the nominal request/response path (expected num. of Fragments and content is correct)


4. test_local_transfer_snbmodules: checks if the content of transferred files are matching with the source files (size and byte-by-byte match)


5. test_bookkeeper_snbmodules: snb bookkeeper reported correctly the transfer registration and state.


**Caveats/extra steps needed**: 


1. The pytest area can result in moderately big size: With 2 data producers, a successful test will results with 2x150MB source files, and their copies after transfer in the destination folder. So in total, the pytest run area will exceed 600MBs! It's advised to remove the pytest run area after successful runs. Potentially, we could add a raw file cleanup to the test itself.


2. During the configuration generation step, the test looks up the IP address of the host. If the hostname is not IP resolvable, this information is not found in the system. The IP address is required for correct behavior of the torrent based transfer implementation.


**Troubleshooting**:
In case the hostname resolvable IP address seems to be a too strict requirement, we should modify the integtest to pass the expected IP address via configuration or command line argument, instead of the following line in the test:

```
L123: ip_addr = socket.gethostbyname(socket.gethostname())
L124: assert ip_addr is not '192.168.0.1' and ip_addr is not 'localhost', 'Hostname resolvable IP address on the host is needed by this test!'
```


## snb_1node_1app_rclone_http_system_quick_test.py

This simple integration test contains a full system integration, exercising recorded SNB file transfer between different processes, running on a single host.
The test exercises the RClone based file transfer implementation served through HTTP protocol, and the SNB recording within the readout subsystem. The test contains a single SNB clientprocess, which has both uploader and downloader sessions.


**Prerequisites:** This test requires an `rclone server` process running, that is serving a remote access point over a protocol. In order to execute this test, there must be an rclone process started as follows:

```
rclone serve http / --addr localhost:8080  --copy-links --dir-cache-time 2s
```

The service is available from a standard DUNE-DAQ workarea environment. The lifetime and usability of this service spans across multiple integtest runs, tests, and any other processes that use `rclone` for file transfers.


**App topology**:
| daq_application(s) |                                      plugin(s), notes                                     |
|:------------------:|:-----------------------------------------------------------------------------------------:|
|      dataflow0     |                            usual integtest topology and config                            |
|         dfo        |                            usual integtest topology and config                            |
|       fakehsi      |                            usual integtest topology and config                            |
|       trigger      |                            usual integtest topology and config                            |
|   rulocalhosteth0  | usual integtest topology and config  (2 fake/sw based WIBEth producers, raw recording on) |
|    snbbookkeper    |                                 1 x SNBTransferBookkeeper                                 |
|      snbclient     |                   2 x SNBFileTransfer (one uploader and one downloader)                   |


**Aim of the test**: Verify that files can be transferred between processes using the RClone HTTP based implementation. For source files, the integtest
uses the readout raw recording features, in order to exercise the file registration ("new file transfer") command of SNBModules (bookkeeper and client).
This also aims to verify the functionality and command sequence between readout and dataflow subsystems. The configuration parameters and aspects of the
RClone based transfer implementation is also demonstrated and tested here.


**Test steps**:


1. Generate default configs for subsystems.


2. Modify `snbmodules` configurations.


3. Add `bookkeeper` to `snbmodules` configuration.


4. Prepare `record-cmd.json` to record raw content for 1 second from every data producers in the `rulocalhosteth0` app.


5. Prepare `new-RClone-transfer.json` expert command for registering a transfer -> source and destination clients and file list. (Protocol arguments: select RClone, HTTP protocol and port to be used -which is specified by the server process spawned in the `prerequisites` subsection of this test description)


6. Prepare `start-transfer.json` expert command to start the upload/download procedure for the registered transfers.


7. Populate nanorc command list:

```
# The commands to run in nanorc, as a list
nanorc_command_list="integtest-partition boot conf start 111 wait 1 enable_triggers wait ".split() + [str(run_duration)] + \
("expert_command /json0/json0/ru" + interface_name + f" {root_path_commands}/record-cmd.json ").split() + \
["wait"] + [str(record_duration)] + \
f"expert_command /json0/json0/snbclient {root_path_commands}/new-RClone-transfer.json ".split() + \
f"expert_command /json0/json0/snbclient {root_path_commands}/start-transfer.json ".split() + \
["wait"] + [str(send_duration)] + "stop_run wait 2 scrap terminate".split()
```


**Pass criteria**:


1. test_nanorc_success: nanorc completed processes return code is 0 (no errors)


2. test_log_files: log files are error free


3. test_data_files: sanity check of the nominal request/response path (expected num. of Fragments and content is correct)


4. test_local_transfer_snbmodules: checks if the content of transferred files are matching with the source files (size and byte-by-byte match)


5. test_bookkeeper_snbmodules: snb bookkeeper reported correctly the transfer registration and state.


**Caveats/extra steps needed**: 


1. The pytest area can result in moderately big size: With 2 data producers, a successful test will results with 2x150MB source files, and their copies after transfer in the destination folder. So in total, the pytest run area will exceed 600MBs! It's advised to remove the pytest run area after successful runs. Potentially, we could add a raw file cleanup to the test itself.


2. There is an extra check before the configuration generation of the test, where it looks for a running `rclone serve http` process/service on the system. If the process is not running, the test immediately fails with an assertion error.


**Troubleshooting**: None


## snb_1node_multiclientapps_rclone_http_system_quick_test.py

This simple integration test contains a full system integration, exercising the same targets as the 1app variant, but uploading the same source files to two target destination clients. Both of the destination clients reside in their own daq_application.


**Prerequisitis, main test steps, and pass criterias are equivalent with the 1app variant. Only the topology is different.**


**App topology**:
| daq_application(s) |                                      plugin(s), notes                                     |
|:------------------:|:-----------------------------------------------------------------------------------------:|
|      dataflow0     |                            usual integtest topology and config                            |
|         dfo        |                            usual integtest topology and config                            |
|       fakehsi      |                            usual integtest topology and config                            |
|       trigger      |                            usual integtest topology and config                            |
|   rulocalhosteth0  | usual integtest topology and config  (2 fake/sw based WIBEth producers, raw recording on) |
|    snbbookkeper    |                                 1 x SNBTransferBookkeeper                                 |
|     snbclient0     |                             1 x SNBFileTransfer (one uploader)                            |
|     snbclient1     |                            1 x SNBFileTransfer (one downloader)                           |
|     snbclient2     |                            1 x SNBFileTransfer (one downloader)                           |



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: roland-sipos_

_Date: Mon Oct 9 17:26:04 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
