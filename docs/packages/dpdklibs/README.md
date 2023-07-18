# dpdklibs - DPDK UIO software and utilities 
Appfwk DAQModules, utilities, and scripts for I/O cards over DPDK.

# Setting up DPDK on NP04
Ensure that the NIC is configured for DPDK based applications:
https://github.com/DUNE-DAQ/dpdklibs/wiki/DPDK-based-NIC-configuration-on-servers

## How to run a system with a transmitter and/or a receiver:
Generate the config with
```
python sourcecode/dpdklibs/scripts/dpdklibs_gen.py -c conf.json dpdk_app
```

where `conf.json` has the parameters that we want to use (see
`schema/dpdklibs/confgen.jsonnet` for a complete list of all the parameters) and
then run it (as root)

```
nanorc dpdk_app partition_name
```

Only the sender and only the receiver can be started with the parameters
`only_sender` and `only_receiver` respectively. This is an example for the
`conf.json` that enables only the sender:

```
{
    "dpdklibs": {
        "only_sender": true
    }
}
```

# Setting up dpdk
For convenience, there is a set of scripts in this repo to set up dpdk, assuming
it has been installed and it works. These scripts have to be run as root. To
begin setting up dpdk, run

```
cd scripts
./kernel.sh
./hugepages.sh
```

The first script loads a new module to the kernel that will be used later to
bind the NICs. The second script sets up [hugepages](https://wiki.debian.org/Hugepages)

Now we have to identify the available NICs, to do that run `dpdk-devbind.py -s`

The output will look like
```
Network devices using kernel driver
============================================
0000:41:00.0 'Ethernet Connection X722 for 10GbE SFP+ 37d3' unused=i40e,uio_pci_generic
0000:41:00.1 'Ethernet Connection X722 for 10GbE SFP+ 37d3' unused=i40e,uio_pci_generic
0000:dc:00.0 'Ethernet Controller 10G X550T 1563' if=enp220s0f0 drv=ixgbe unused=uio_pci_generic 
0000:dc:00.1 'Ethernet Controller 10G X550T 1563' if=enp220s0f1 drv=ixgbe unused=uio_pci_generic *Active*
```
in this case the ones that we want to use for dpdk are the first two so we have to bind them. Modify `bind.sh`
to match the two addresses that we just found (in this case 0000:41:00.0 and 0000:41:00.1) and run
```
./bind.sh
```

Now if we run `dpdk-devbind.py -s` the output should look like this:
```
Network devices using DPDK-compatible driver
============================================
0000:41:00.0 'Ethernet Connection X722 for 10GbE SFP+ 37d3' drv=uio_pci_generic unused=i40e
0000:41:00.1 'Ethernet Connection X722 for 10GbE SFP+ 37d3' drv=uio_pci_generic unused=i40e

Network devices using kernel driver
===================================
0000:dc:00.0 'Ethernet Controller 10G X550T 1563' if=enp220s0f0 drv=ixgbe unused=uio_pci_generic 
0000:dc:00.1 'Ethernet Controller 10G X550T 1563' if=enp220s0f1 drv=ixgbe unused=uio_pci_generic *Active*
```
where the NICs that we wanted appear under `Network devices using DPDK-compatible driver`

# Troubleshooting


* EAL complains about `No available 1048576 kB hugepages reported`


* `ERROR: number of ports has to be even`
  This happens when the interfaces are not bound. See instructions above on
  binding the interfaces, modify `scripts/bind.sh` and run it


# Tests and examples
There are a set of tests or example applications

## `dpdklibs_test_transmit_and_receive`
If you're on a host which contains two dpdk-enabled interfaces, you can run `dpdklibs_test_transmit_and_receive`. This app will send packets out of one interface on the host and receive them on the other. It will also keep track of the # of packets sent and received per second, the total # of bytes sent and received per second, and the number of packets which are received as corrupted per second (hopefully zero). Each packet is literally an ethernet header + an IPv4 header + a UDP header + a `detdataformats::DAQEthHeader` + a payload of zeros. The default length of the payload is 9000 bytes, but you can adjust this via the `--payload` argument; e.g. `dpdklibs_test_transmit_and_receive --payload 0` would send packets with no payload. 

##  `dpdklibs_test_frame_transmitter` / `dpdklibs_test_frame_receiver`

`dpdklibs_test_frame_transmitter` and `dpdklibs_test_frame_receiver` only individually require a host with a single dpdk-enabled interface. A very common idiom is to run `dpdklibs_test_frame_receiver` receiving packets on the interface of one host and to run `dpdklibs_test_frame_transmitter` sending packets on the interface of another host. 

For `dpdklibs_test_frame_transmitter`, you'll generally want to supply it with the MAC address of the interface which you want to have receive the packets it transmits. Also, while it sends packets with payloads just like `dpdklibs_test_transmit_and_receive`, it defaults them to 0. So, e.g., to send packets with 9KB of payload to an interface with a MAC address of `6c:fe:54:47:98:20` (available on `np02-srv-002` as of May-7-2023) you could run the following: `dpdklibs_test_frame_transmitter --dst-mac 6c:fe:54:47:98:20 --payload 9000`

To receive the packets sent by `dpdklibs_test_frame_transmitter`, you can run `dpdklibs_test_frame_receiver`. You can also use it to receive packets from actual WIBs. If you're receiving packets from `dpdklibs_test_frame_transmitter`, you should see lines like the following:
```
Stream (1, 2, 3, 4)   : n.pkts 0 (tot. 23786829)
```
...since `dpdklibs_test_frame_transmitter` intentionally constructs the `detdataformats::DAQEthHeader` in its packets to have a `det_id` of 1, a `crate_id` of 2, a `slot_id` of 3, and a `stream_id` of 4.  

## Configuring stats reporting from the `NICReceiver`

The way packet statistics are reported from the `NICReceiver` is on a per-interface basis. An example JSON snippet which can control this reporting is as follows:
```
                "ifaces": [
                    {
                        "stats_reporting_cfg": {
                            "expected_packet_size": 7243,
                            "expected_timestamp_step": -1,
                            "expected_seq_id_step": 1,                          
                            "analyze_nth_packet": 2                        
                        },
                        ...
```
This tells the interface to check that the packet size is 7243 bytes, to ignore the timestamp (any negative value for a variable beginning with `expected_` means "ignore"), and to check the sequence ID step is 1. It also tells it to only do this for every other packet, as a way of saving computation time. Note that all these variables have defaults and thus `"stats_reporting_cfg"` doesn't need to be defined if the defaults are satisfactory; these defaults are: expect a sequence ID step of 1 for each new packet in a stream, a packet size of 7243 bytes, ignore the timestamp, and analyze all packets. 


  


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Thu Jul 6 13:15:54 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dpdklibs/issues](https://github.com/DUNE-DAQ/dpdklibs/issues)_
</font>
