# How to route messages to specific handlers

This page explains how to direct individual log records to specific handlers using `HandlerType` tokens and `LogHandlerConf`.

For background on *why* routing works this way, see [Concepts](../explanation.md).

---

## Choosing handlers with HandlerTypes and the extra keyword

You can route individual records to specific handlers by using `extra={"handlers": [...]}`:

```python
from daqpytools.logging import HandlerType

log = get_daq_logger("example", rich_handler=True, file_handler_path="logging.log")

log.info("This will only go to Rich", extra={"handlers": [HandlerType.Rich]})
log.info("This will only go to File", extra={"handlers": [HandlerType.File]})
log.info("You can even send to both", extra={"handlers": [HandlerType.Rich, HandlerType.File]})
```

Note: Asking for a handler type that isn't attached is a no-op. Using `HandlerType.Stream` in the example above (when only Rich and File are attached) will be silently ignored.

---

## Using LogHandlerConf for structured routing

`LogHandlerConf` is a configuration dataclass that encapsulates the handler setup for different streams. It can handle ERS environment variable parsing and creates routing metadata bundles that you attach to records via `extra`.

### Understanding LogHandlerConf

The ERS configuration is defined in OKS and automatically parsed by daqpytools. A key feature: **handlers are severity-level dependent**. ERS Fatal and ERS Info may have different handler requirements.

`LogHandlerConf` manages this complexity:

```python
from daqpytools.logging import LogHandlerConf

handlerconf = LogHandlerConf()

# Access router metadata for each stream
main_logger.warning("Handlerconf Base", extra=handlerconf.Base)
main_logger.warning("Handlerconf Opmon", extra=handlerconf.Opmon)
```

This passes the appropriate handler routing metadata so the record is emitted to the right handlers for that stream.

### Initialize ERS streams lazily

By default, `LogHandlerConf` does not initialize the ERS stream because it requires ERS environment variables. You can initialize it later when ERS becomes available:

```python
# By default init_ers is false
LHC = LogHandlerConf()  # ERS not initialized yet

print(LHC.Base)  # Success
print(LHC.ERS)   # Throws: ERS stream not initialised

# Later, when ERS envs are set
LHC.init_ers_stream()
print(LHC.ERS)   # Success
```

Or initialize upfront if ERS vars are already defined:

```python
LHC_with_ers = LogHandlerConf(init_ers=True)
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Emir Muhammad_

_Date: Tue Apr 14 15:55:02 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
