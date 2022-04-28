# dtpctrllibs

This package contains DAQ modules for controlling DUNE Trigger Primitive generation firmware.

## DTPController

This is the module which controls TP firmware. It is a very simple module, with no I/O queues.  It responds to several RC commands :

   * conf : this command will establish the connection to the firmware (ipbus over flx), issue a reset, and then configure it

   * reset : this command just resets firmware

   * start : enables TP production

   * stop  : disables TP production

### Configuration

Currently, the only useful configuration data are the input source (internal or external) and the TP threshold.

Channel masks still need to be implemented, as well as control over the firmware topology (ie. numbers of links, pipelines, etc.)


### Monitoring

No data is monitored yet.


## Running tests

A quick recipe for running tests.

```
python -m dtpctrllibs.dtp_app_confgen dtp_app.json
daq_application --name dtp_app -c stdin://dtp_app.json
```

At the terminal that now appears, run 'init', 'conf', 'enable' commands in order to produce TPs.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Jim B_

_Date: Tue Apr 5 13:14:57 2022 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dtpctrllibs/issues](https://github.com/DUNE-DAQ/dtpctrllibs/issues)_
</font>
