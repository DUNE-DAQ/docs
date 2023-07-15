# daq-systemtest README
If using bristol or iceberg configurations, an instance of the connectivity service needs to be started, e.g.: 
```
gunicorn -b 0.0.0.0:15432 --workers=1 --worker-class=gthread --threads=4 --timeout 5000000000 connection-service.connection-flask:app
```
The timing sessions do not start the connectivity service because they apply a port offset. The CERN configurations make use of the already existing NP04 connectivity service.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Stoyan Trilov_

_Date: Fri Jul 14 10:29:31 2023 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-systemtest/issues](https://github.com/DUNE-DAQ/daq-systemtest/issues)_
</font>
