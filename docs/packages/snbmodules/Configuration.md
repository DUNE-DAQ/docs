# Configuration
This module need to be configured with a bunch of parameters to start properly in dune DAQ. 

[Have a look to the example configuration folder provided here.](https://github.com/DUNE-DAQ/snbmodules/tree/leo-initial-merge/snbconfig)

The configuration folder contain differents files:
- boot.json : allow to boot the different snbmodules applications on differents hosts. see [Boot file section for more information.](<#Boot file>)
- init.json : link applications to data/snbmodulesX_init.json files. Initialize connections and declare modules to start in the application (every application have his own snbmodulesX_init.json file). see [Init file section for more information.](<#Init file>)
- conf.json : link applications to data/snbmodulesX_conf.json files. Contain the configuration and options of each modules (Clients and Bookkeeper), see [Conf file section for more information.](<#Conf file>)

Once the configuration folder is setup, you can start the environment:

```
nanorc sourcecode/snbmodules/snbconfig/ snb
boot
conf
start 1
```

# Boot file
Add the apps/package in the booting configuration. One should exist for every host starting a client or a bookkeeper.

<details>
  <summary>Show example Code</summary>

```
"apps": {
        "snbmodules0": {
            "exec": "daq_application_ssh",
            "host": "snbmodules0",
            "port": 3333
        },
        "snbmodules1": {
            "exec": "daq_application_ssh",
            "host": "snbmodules1",
            "port": 3334
        }
    },
    ...
    "hosts-ctrl": {
        "snbmodules0": "hostname",
        "snbmodules1": "hostname"
    },
    "hosts-data": {
        "snbmodules0": "hostname",
        "snbmodules1": "hostname"
    },
```

</details>

# Init file
Connection names must start with 'snbmodules' or  then client or bookkeeper :
- snbmodules_bookkeeper_notification_0x00000000
- snbmodules_client0_notification_0x00000000

Important note : every snbmodulesX_conf.json files must contain **every connection across all hosts** for now. For example, we declare the connection for the module client2 in the configuration of every application on every hosts, and so in every snbmodulesX_conf.json files.

<details>
  <summary>Show example Code</summary>

```
{
    "connections": [
        {
            "connection_type": "kSendRecv",
            "id": {
                "data_type": "notification_t",
                "session": "",
                "uid": "snbmodules_bookkeeper_notification_0x00000000"
            },
            "uri": "tcp://{snbmodules0}:12649"
        },
        {
            "connection_type": "kSendRecv",
            "id": {
                "data_type": "notification_t",
                "session": "",
                "uid": "snbmodules_client0_notification_0x00000000"
            },
            "uri": "tcp://{snbmodules0}:12648"
        },
        {
            "connection_type": "kSendRecv",
            "id": {
                "data_type": "notification_t",
                "session": "",
                "uid": "snbmodules_client1_notification_0x00000001"
            },
            "uri": "tcp://{snbmodules0}:12647"
        },
        {
            "connection_type": "kSendRecv",
            "id": {
                "data_type": "notification_t",
                "session": "",
                "uid": "snbmodules_client2_notification_0x00000002"
            },
            "uri": "tcp://{snbmodules1}:12646"
        }
    ],
    "connectivity_service_interval_ms": 1000,
    "modules": [
        {
            "inst": "bookkeeper",
            "plugin": "SNBTransferBookkeeper"
        },
        {
            "inst": "client0",
            "plugin": "SNBFileTransfer"
        },
        {
            "inst": "client1",
            "plugin": "SNBFileTransfer"
        }
    ],
    "queues": [],
    "use_connectivity_service": false
}
```

</details>

# Conf file
## Bookkeeper params
- "bookkeeper_ip" : string (mandatory) The IP address used by the Bookkeeper to receive/send notifications
- "bookkeeper_log_path" : string (default:"./") Path where record transfer data in csv file and graphical bookkeeper.log interface for monitoring. leave empty "" to disable
- "refresh_rate" : int (default:5) Refresh rate of bookkeeper logs in seconds

## Client params
- "client_ip" : string format IPV4:PORT (mandatory) The IP address used by the client, you can precise the interface used here
- "work_dir" : string (default:"./") Directory where the client is gonna watch for files to share with Bookkeeper and where files are Downloaded by default (uploaded files don't have to be in here)

## Global params
- "connection_prefix" : string (default:"snbmodules") prefix of the connections name, for the plugin to find others connections
- "timeout_send" : int (default:10) max time in ms passed sending a notification
- "timeout_receive" : int (default:100) max time in ms listening for a notification

<details>
  <summary>Show example Code</summary>

```
{
    "modules": [
        {
            "data": {
                "bookkeeper_ip": "192.168.0.106:0",
                "bookkeeper_log_path": "./",
                "connection_prefix": "snbmodules",
                "timeout_send": 100,
                "timeout_receive": 100,
                "refresh_rate": 5
            },
            "match": "bookkeeper"
        },
        {
            "data": {
                "client_ip": "192.168.0.106:5010",
                "work_dir": "/mnt/md1/client0",
                "connection_prefix": "snbmodules",
                "timeout_send": 100,
                "timeout_receive": 100
            },
            "match": "client0"
        },
        {
            "data": {
                "client_ip": "192.168.0.105:5011",
                "work_dir": "/mnt/md1/client1",
                "connection_prefix": "snbmodules",
                "timeout_send": 100,
                "timeout_receive": 100
            },
            "match": "client1"
        }
    ]
}
```

</details>

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Leo Joly_

_Date: Fri Sep 22 18:12:31 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
