# Local driver
## What is the "local" driver?
In order to ensure absolute consistency with the software externals, the DUNE readout external packages from the ATLAS FELIX Software Suite are built in-house and deployed as external products. Hence the reason, the driver being a foundation that connects firmware with software, it is also part of this product.

## Build and start script
With `sudo` rights or as `root` one can use the [setup_felix_driver.sh](https://github.com/DUNE-DAQ/flxlibs/tree/develop/scripts/setup_felix_driver.sh) script to build and start the drivers.

## How to build and start it, step by step
With `sudo` rights or as `root` one needs to do the following steps:
```
mkdir -p /opt/felix
cp -r /cvmfs/dunedaq.opensciencegrid.org/products/felix/v1_2_2 /opt/felix/
if [[ `lsb_release -rs` == 8 ]]; then cd /opt/felix/v1_2_2/Linux64bit+4.18-2.28-e19-prof/drivers_rcc/src/; else cd /opt/felix/v1_2_2/Linux64bit+3.10-2.17-e19-prof/drivers_rcc/src/; fi;
make -j
cd ../script
sed -i 's/gfpbpa_size=4096/gfpbpa_size=8192/g' ./drivers_flx_local
./drivers_flx_local stop
./drivers_flx_local start
./drivers_flx_local status
```

The expected output is similar to this:

```
[root@host script]# ./drivers_flx_local status
cmem_rcc             8431913  0 

>>>>>> Status of the cmem_rcc driver


CMEM RCC driver (FELIX release 4.5.0)

The driver was loaded with these parameters:
gfpbpa_size    = 8192
gfpbpa_quantum = 4
gfpbpa_zone    = 0
numa_zones     = 1

alloc_pages and alloc_pages_node
   PID | Handle |         Phys. address |               Size | Locked | Order | Type | Name

GFPBPA (NUMA = 0, size = 8192 MB, base = 0x00000013b1000000)
   PID | Handle |         Phys. address |               Size | Locked | Type | Name
 
The command 'echo <action> > /proc/cmem_rcc', executed as root,
allows you to interact with the driver. Possible actions are:
debug    -> enable debugging
nodebug  -> disable debugging
elog     -> Log errors to /var/log/messages
noelog   -> Do not log errors to /var/log/messages
freelock -> release all locked segments
io_rcc                 21598  0 

>>>>>> Status of the io_rcc driver

IO RCC driver for release tdaq831_for_felix (based on tag ROSRCDdrivers-00-01-00)
Dumping table of linked devices
Handle | Vendor ID | Device ID | Occurrence | Process ID
 
The command 'echo <action> > /proc/io_rcc', executed as root,
allows you to interact with the driver. Possible actions are:
debug   -> enable debugging
nodebug -> disable debugging
elog    -> Log errors to /var/log/messages
noelog  -> Do not log errors to /var/log/messages
Current values of the parameter(s)
debug    = 0
errorlog = 1
flx                    43300  0 

>>>>>> Status of the flx driver 

FLX driver 4.5.0 for RM4 F/W only

Debug                         = 0
Number of devices detected    = 2


Locked resources
      device | global_locks
=============|=============
           0 |   0x00000000
           1 |   0x00000000

Locked resources
device | resource bit |     PID |  tag
=======|==============|=========|=====

Error: Device 0 does not have the required F/W. The regmap register contains 0x00000500

Error: This version of the driver is for regmap 4.0

Error: Device 1 does not have the required F/W. The regmap register contains 0x00000500

Error: This version of the driver is for regmap 4.0
 
The command 'echo <action> > /proc/flx', executed as root,
allows you to interact with the driver. Possible actions are:
debug     -> Enable debugging
nodebug   -> Disable debugging
elog      -> Log errors to /var/log/message
noelog    -> Do not log errors to /var/log/message
swap      -> Enable automatic swapping of 0x7038 / 0x7039 and 0x427 / 0x428
noswap    -> Disable automatic swapping of 0x7038 / 0x7039 and 0x427 / 0x428
clearlock -> Clear all lock bits (Attention: Close processes that hold lock bits before you do this)
```

Please ignore the last errors which are complaining about regmap missmatch.



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: roland-sipos_

_Date: Tue Apr 26 10:19:16 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/flxlibs/issues](https://github.com/DUNE-DAQ/flxlibs/issues)_
</font>
