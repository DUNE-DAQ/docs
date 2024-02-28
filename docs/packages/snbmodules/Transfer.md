# Transfers with SNBmodules

Once you have successfully setup the full environment, it's now time to move files around !

## Nomenclature


* Bookkeeper : Monitor every transfers

* Transfer metadata : Contain file and transfer information

* TransferClient : Client containing sessions exchanging files

* Group metadata : Contain multiple Transfer metadata uploaded by the same host

SNBmodules - General flow             |  SNBmodules - User interaction RClone http
:-------------------------:|:-------------------------:
![SNBmodules - General flow](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/2f7b2595-f7d5-4cf2-88fb-c537846653af)  |  ![User interaction](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/a5d7a0b0-54e7-4ddf-b364-de2045593278)



## Special note Rclone http server

It is recommended to use RCLONE with http protocol. For allow transfer to happen, you need to initialize the http server on you Uploader Client with this command:

```
in the previously installed rclone/rclone-v1.63.1-linux-amd64 library :
./rclone serve http / --addr IP_OF_UPLOADER_CLIENT:8080 --buffer-size '0' --no-modtime --transfers 200 -v --multi-thread-cutoff=50G --multi-thread-streams=16
```

notes : 
- you can select the PORT here and you need to open this port to TCP connections, the IP must be identical with Uploader IP.
- The default shared path '/' is not mandatory and you will need to modify the "root_folder" parameter of rclone new transfer accordingly.

## Create and execute commands

Once the nanorc is booted, initialized and started, you can start sending commands. You can find a bash script to create and execute commands more simply in [./sourcecode/snbmodules/snbconfig/commands/command_generator.sh](https://github.com/DUNE-DAQ/snbmodules/blob/leo-initial-merge/snbconfig/commands/command_generator.sh) or you can see detailed information in the [Custom commands](#Custom commands) section.

## Log files

You can monitor your transfers via the bookkeeper.log file that show currents transfers and information about status.
There is also bookkeeper_line.csv file that record parsable data of transfers.

These files are created in the Bookkeeper configuration : "bookkeeper_log_path".

## Example full setup
![image](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/5894e2e9-680e-4d66-9264-c9e802d515e2)
You can see nanorc with started application in the top left corner, the bookkeeper log file in the top right corner, the rclone http server in the bottom left corner and the command generator tool in the bottom right corner.

![nanorc](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/9cb180dd-a66a-4dbb-9df8-a5ac6efaf93c)  |  ![bookkeeper_log](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/d88c8586-3974-4a28-b94a-b54df194c468)
:-------------------------:|:-------------------------:
![http_server](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/fab7dbbf-96ee-4ce2-9fac-355f65f23aaa)  |  ![command_generator](https://github.com/DUNE-DAQ/snbmodules/assets/31961987/5d051251-c7bb-481a-bda7-5bebc4f8417b)



## Custom commands
### Bookkeeper

- Collect data from clients

<details>
  <summary>Show example Code</summary>

```
{
    "_comment_post_command": "curl --header 'Content-Type: application/json' --header 'X-Answer-Port: 56789' --request POST --data @test1/commands/bk-info.json http://localhost:3333/command",
    "data": {
        "modules": [
            {
                "data": {},
                "match": ""
            }
        ]
    },
    "id": "info"
}
```

</details>

### Client

- New group transfer : only for the Uploader Client of the transfer
    - Only one source (Uploder) to multiple clients (Dowloaders) per group transfer
    - Parameters : 
        - "transfer_id" : string (mandatory) Name of the transfer
        - "files" : array<string> (mandatory) List of files full path to send
        - "src" : string (mandatory) Name of the source (Uploader) Client
        - "dests" : array<string> (mandatory) Names of the destinations Clients (Downloaders)
        - "protocol" : enum (mandatory) Choice of the protocol used for the transfer
            - SCP
            - BITTORRENT
            - RCLONE
        - "protocol_args" : JSON (optional/mandatory) JSON of parameters for the protocol, they change depending on the protocol
            - SCP params
                - "user" : String (mandatory) Name of the username to use for the transfer
                - "use_password" : bool (default:false) Request password to the user (only for stand-alone application)
            - BITTORRENT parameters
                - "port": int (mandatory) Listening port of the BitTorrent client
                - "rate_limit": int (default:-1) rate limit of the transfer in bytes/second, -1 for unlimited 
            - RCLONE parameters
                - "protocol": string (default:"http") RClone param to select protocol used, supported : "http", "sftp"
                - "user": string (mandatory for sftp only) username if using sftp
                - "rate_limit": string (default:"off") Rate limiter for the transfer, for 1 GiB put "1GiB" and "off" for unlimited
                - "port": int (default:8080) Port of the HTTP server in the source Client (Uploader) if using HTTP
                - "refresh_rate": int (default:5) Seconds before RClone request transfer information of transferring files
                - "simult_transfers": int (default:200) Number of allowed concurrent connection for a transfer
                - "transfer_threads": int (default:1) Number of threads that will write the file per file transferred
                - "checkers_threads": int (default:2) Number of threads that will Hash and check the file per file transferred
                - "chunk_size": string (default:"8GiB") Chunk to split each file, this will create a new connection for each chunk
                - "buffer_size": string  (default:"0") Buffer size allocated, for 1 GiB put "1GiB"
                - "use_mmap": bool (default:false) Use memory map
                - "checksum": bool (default:true) Check sum of the file once downloaded (or on flight)
    - "match": string (mandatory) The match must be equal to src parameter.


```
{
    "_comment_post_command": "curl --header 'Content-Type: application/json' --header 'X-Answer-Port: 56789' --request POST --data @test1/commands/new-RClone-transfer.json http://localhost:3333/command",
    "data": {
        "modules": [
            {
                "data": {
                    "transfer_id": "transfer2",
                    "files": [
                        "/mnt/md1/small_32_block_0",
                        "/mnt/md1/small_32_block_1",
                        "/mnt/md1/small_32_block_2",
                        "/mnt/md1/small_32_block_3",
                        "/mnt/md1/small_32_block_4",
                        "/mnt/md1/small_32_block_5",
                        "/mnt/md1/small_32_block_6",
                        "/mnt/md1/small_32_block_7",
                        "/mnt/md1/small_32_block_8",
                        "/mnt/md1/small_32_block_9"
                    ],
                    "src": "client0",
                    "dests": [
                        "client2"
                    ],
                    "protocol": "RCLONE",
                    "protocol_args": {
                        "protocol": "http",
                        "rate_limit": "off",
                        "port": 8080,
                        "refresh_rate": 5,
                        "user": "username",
                        "simult_transfers": 200,
                        "transfer_threads": 1,
                        "checkers_threads": 2,
                        "chunk_size": "8GiB",
                        "buffer_size": "0",
                        "use_mmap": false,
                        "checksum": true
                    }
                },
                "match": "client0"
            }
        ]
    },
    "id": "new-transfer"
}
```


- Start transfer

Simply indicate the name of the transfer to apply the command to with "transfer_id" parameter and the Uploader client in the "match" option.


```
{
    "_comment_post_command": "curl --header 'Content-Type: application/json' --header 'X-Answer-Port: 56789' --request POST --data @test1/commands/start-transfer.json http://localhost:3333/command",
    "data": {
        "modules": [
            {
                "data": {
                    "transfer_id": "transfer0"
                },
                "match": "client0"
            }
        ]
    },
    "id": "start-transfer"
}
```

- Pause transfer

```
{
    "_comment_post_command": "curl --header 'Content-Type: application/json' --header 'X-Answer-Port: 56789' --request POST --data @test1/commands/pause-transfer.json http://localhost:3333/command",
    "data": {
        "modules": [
            {
                "data": {
                    "transfer_id": "transfer0"
                },
                "match": "client0"
            }
        ]
    },
    "id": "pause-transfer"
}
```


- Resume transfer


```
{
    "_comment_post_command": "curl --header 'Content-Type: application/json' --header 'X-Answer-Port: 56789' --request POST --data @test1/commands/resume-transfer.json http://localhost:3333/command",
    "data": {
        "modules": [
            {
                "data": {
                    "transfer_id": "transfer0"
                },
                "match": "client0"
            }
        ]
    },
    "id": "resume-transfer"
}
```


- Cancel transfer


```
{
    "_comment_post_command": "curl --header 'Content-Type: application/json' --header 'X-Answer-Port: 56789' --request POST --data @test1/commands/cancel-transfer.json http://localhost:3333/command",
    "data": {
        "modules": [
            {
                "data": {
                    "transfer_id": "transfer0"
                },
                "match": "client0"
            }
        ]
    },
    "id": "cancel-transfer"
}
```

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Leo Joly_

_Date: Fri Sep 22 18:12:31 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
