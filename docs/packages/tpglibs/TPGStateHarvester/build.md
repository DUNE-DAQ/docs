# Note regarding building `tpglibs` with state harvester ON/OFF

In order to turn on internal state collection, CMAKE variable `TPGLIBS_ENABLE_STATE_MONITORING` needs to be on. `dbt-build` doesn't directly expose an option. The solution is to export a variable before building.

In order to enable state harvester (OFF by default), run

```
  export TPGLIBS_ENABLE_STATE_MONITORING=ON
  dbt-build -c
```

A clean rebuild is needed to apply the change (`dbt-build -c`).

In order to disable state harvester, follow the same procedure with "ON" replaced by "OFF", or by unsetting the variable

```
  unset TPGLIBS_ENABLE_STATE_MONITORING
  dbt-build -c
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Theo Yu_

_Date: Tue Aug 25 15:27:02 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/tpglibs/issues](https://github.com/DUNE-DAQ/tpglibs/issues)_
</font>
