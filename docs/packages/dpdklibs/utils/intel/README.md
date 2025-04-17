# Intel NIC Setup


**Work in progress**


* Set MTUs to Jumbi frames

* Configure hugepages using dpdk utility script
    - Do we need `dpdk-hugepages.py`?


```
    sudo cp 52-hugepages.rules /etc/udev/rules.d/
    sudo cp 53-vfio.rules /etc/udev/rules.d/
```

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Alessandro Thea_

_Date: Wed Feb 8 22:19:25 2023 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dpdklibs/issues](https://github.com/DUNE-DAQ/dpdklibs/issues)_
</font>
