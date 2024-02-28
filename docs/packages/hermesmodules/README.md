# Hermes Modules

## Configuring the ZCU102 design to send fake data

The Hermes core can be monitored, controlled and configured using the `hermesbutler.py` script.
This script is part of the `hermesmodules` DUNE-DAQ package. It requires a DUNE-DAQ release or area.

The other ingredients to set up the Hermes core to transmit data to a network endpoint are:



1. The hermes ipbus connection details


2. the hermes link mac and ip addresses (and port)


3. the receiver link mac and ip addresses (and port)


4. A handful of parameters.

In order to simplify the handling of these parametrs, all the connection details are specified in configuration files and only the connection names are exposed to the `hermesbutler` command line.

- Hermes IPbus control endpoint details are specified in the `${HERMESMODULES_SHARE}/config/c.xml` connection file.
Information about IPBus connection files are available on the IPbus [User Guide](https://ipbus.web.cern.ch/doc/user/html/software/uhalQuickTutorial.html#connecting-to-the-hardware-ip-endpoint-with-a-connection-file).
- The transmitter endpoints details are defined in the `${HERMESMODULES_SHARE}/config/tx_endpoints.json` file.
- The receiver endpoints details are defined in the `${HERMESMODULES_SHARE}/config/tx_endpoints.json` file.

The content of these configuration files can be visualized `hermesbutler.py addrbook`.
Once all the information have been inserted, the sequence of commands to set-up the endpoint is:

```sh
hermesbutler.py -d <device id> enable -l <link> --dis 
hermesbutler.py -d <device id> udp-config -l <link> <rx endpoint> <tx endpoint>
hermesbutler.py -d <device id> mux-config -l <link> 1 2 3
hermesbutler.py -d <device id> fakesrc-config -l <link> -n 4
hermesbutler.py -d <device id> enable -l <link> --en
hermesbutler.py -d <device id> stats -l <link>
```

## Hermes IPbus UDP-to-Axi bridge

### Installation

Installing the ipbus bridge requires compiling the bridge code on the zynq PS and running the bridge from terminal or as a service. `gcc`

Log in onto the Zynq PS. Clone the `hermesmodules` via git or by downloading a tarball.

```sh
git clone https://github.com/DUNE-DAQ/hermesmodules.git -b <tag or branch>
```
or
```sh
curl -o <path to tarball on GitHub>
tar xfvz <tarball>
```

Compile the bridge code with make

```sh
cd zynq
make
```

*Optional*: Install `hermes_udp_srv` system-wide 


* On the ZCU102

    ```sh
    sudo make install-zcu102
    ```


* On the WIBs
    ```sh
    sudo make install-zcu102
    ```

## Running `hermes_udp_srv`

When installed system-wide, the `hermes_udp_srv` is started automatically at boot.
If not, the service can be started from commandline

```
Usage: ./hermes_udp_srv [options...]
Options:
    -d, --device           device type             (Required)
    -v, --verbose          verbosity level        
    -c, --check-replies-countCheck Replies count    
    -h, --help             Shows this page        
```



* On the ZCU102
    ```sh
    sudo /bin/hermes_udp_srv -d zcu102 
    ```


* On the WIBs
    ```sh
    sudo /bin/hermes_udp_srv -d wib -c false 
    ```




-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Alessandro Thea_

_Date: Thu May 11 15:59:00 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/hermesmodules/issues](https://github.com/DUNE-DAQ/hermesmodules/issues)_
</font>
