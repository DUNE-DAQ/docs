# Troubleshooting reference

This page lists common symptoms, their likely causes, and fixes.

For a systematic debugging workflow when extending the system, see the [developer debugging checklist](../../../dev/how-to/debug-routing/).
---

| Symptom | Likely cause | What to check | Fix |
|---|---|---|---|
| `Logger ... already exists with different handler configuration` | Same logger name reused with different constructor flags | Logger name and previous initialization path | Reuse same config for that name, or choose a new logger name |
| `Root logger ... already has handlers configured` | `setup_root_logger` called after handlers were already attached | Existing handlers on the named root logger | Use a fresh logger name or clear handlers before setup |
| Throttle filter appears to do nothing | `HandlerType.Throttle` is not in resolved allowed handlers for that record | `extra={"handlers": ...}` and stream metadata | Add `HandlerType.Throttle` to routing metadata for the messages you want throttled |
| ERS stream access raises `ERS stream not initialised` | `LogHandlerConf` created with `init_ers=False` and ERS not initialized yet | Whether `init_ers_stream()` was called | Call `init_ers_stream()` after ERS env vars are present |
| ERS setup fails due to missing env | One or more required `DUNEDAQ_ERS_*` variables are unset/empty | Environment before ERS init/setup | Export required ERS variables before initializing ERS |
| ERS setup fails with multiple protobuf endpoints | ERS env vars define different `protobufstream(url:port)` targets by severity | Parsed ERS vars across severities | Use one shared endpoint in Python setup path |
| Message not emitted to expected handler | Requested handler not attached or filtered out by routing | Attached handlers and `extra["handlers"]` values | Attach the handler at logger setup and include the right `HandlerType` on the record |


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Emir Muhammad_

_Date: Wed Apr 15 15:41:46 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
