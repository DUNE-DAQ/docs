# First time setup for AMCs.

This Document contains procedure on how to enable control and readout of the AMCs in the event the server loose connection to the uTCA crates or the crates are connected for the first time. Documentation uses the TDE test crate IP in the examples.

### 1.
First, ensure the host machine for reading out the AMCs is correctly setup (readout server for the test crate is np02-srv-002).
```
dpdk-devbind.py -s
```

Should show some NICs using the DPDK compatible drivers. If there are none, then run
```
sudo /opt/setup-100g-vfio.sh
```
### 2.
Next, make sure the uTCA crate is pingable from the host machine for controlling the AMCs (np04-srv-011). if you get no response doing

```
arping 10.73.32.129 # or 1073.32.X.129 for another crate
```

then the 10G interface needs to be configured through `nmcli` (contact sysadmins).
(was there any other steps to do here?)

### 3.
If the above is correctly setup, perform a first time boot of the AMCs. This requires sending ARP commands through the same network interface used to readout the the AMCs. To do so, start a run with the only the readout application enabled for the. For the test crate this involves disabling the tde crate application in the segment file (`segments/tde-testcrate.data.xml`):

```
<obj class="Segment" id="tde-testcrate-segment">
 <rel name="applications">
  <ref class="ReadoutApplication" id="runp02srv002eth1"/>
  <ref class="TDECrateApplication" id="tde-testcrate-application"/>  <!-- comment this out -->
 </rel>
 <rel name="controller" class="RCApplication" id="tde-testcrate-controller"/>
</obj>

```

and run `drunc`
```
drunc-unified-shell ssh-CERN-kafka ehn1-daqconfigs/sessions/tde-testcrate.data.xml tde-testcrate-session $USER-tde-test

# in the drunc shell
boot
conf
start --run-type test
```

Now commands can be sent to the AMCs to initialize them (how is this done?)

The run can now be stopped
```
# in the drunc shell
drain-dataflow
stop
scrap
terminate
exit
```

It should now be possible to send commands to the AMCs using the modules provided in `tdemodules`.

Undo the changes to `segments/tde-testcrate.data.xml`!

### 4.

You should be able to send commands and get the status of the AMCs using `test_amc_status.py` from the host machine for controlling the AMCs  (np04-srv-011)
```
test_amc_satus.py -c 10.73.32.128 # to check all possible IPs from a crate
test_amc_satus.py -c 10.73.32.2 # too check a single AMC
```
and this should not produce any error messages in the printout.

<!-- You should be able to send commands and get the status of the AMCs using the `run_tde_amc` script:

```
git clone https://gitlab.in2p3.fr/dune-tde/tde-amc-control.git
cd tde-amc-control
./run_tde_amc -c 10.73.32.128 # or another crate ip.
```

***Would be worth making a simple script that can check whether an AMC/Crate is accessible in tdemodules***. -->

### 5.

Ensure the timing is initialized for the frontend electronics

### 6.

The system should be fully setup and a run can be taken. For the TDE test crate:

```
drunc-unified-shell ssh-CERN-kafka ehn1-daqconfigs/sessions/tde-testcrate.data.xml tde-testcrate-session $USER-tde-test

# in the drunc shell
boot
conf
start --run-type test
enable-triggers
```

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: ShyamB97_

_Date: Thu Jun 5 13:13:49 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/tdemodules/issues](https://github.com/DUNE-DAQ/tdemodules/issues)_
</font>
