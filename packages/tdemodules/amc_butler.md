# AMC Butler

The AMC Butler can be used to `start`, `stop` and get the `status` of a crate:

```
amc_butler.py -c <crate_ip> --command <command>
```

or multiple AMCs:

```
amc_butler.py -a <amc_ips> --command <command>
```

The `start` and `stop` command are issued once for each AMC sequentially, while the status command runs indefinately and get the status of the AMCs every 10 s.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: sbhuller_

_Date: Tue Jul 15 19:17:31 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/tdemodules/issues](https://github.com/DUNE-DAQ/tdemodules/issues)_
</font>
