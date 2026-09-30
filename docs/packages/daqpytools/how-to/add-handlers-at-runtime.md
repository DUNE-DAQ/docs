# How to add handlers at runtime

Loggers and their respective handlers can be configured in two ways.



1. Build a logger first with `get_daq_logger(...)`. This is covered in the [getting started tutorial](../tutorial.md)/.


2. Add more handlers/filters later, based on runtime context. This is covered in this page.

This is useful in long-running services where extra outputs (for example ERS Kafka) should only be attached after additional configuration becomes available.

---

## Add one handler at a time with `add_handler`

Use `add_handler` if you want to attach a single handler type to an existing logger.

```python
from daqpytools.logging import HandlerType, add_handler, get_daq_logger

log = get_daq_logger(
    logger_name="existing_logger",
    rich_handler=True,
    stream_handlers=False,
)

# Add stdout stream handler later
add_handler(log, HandlerType.Lstdout, use_parent_handlers=True)

log.info("Now routes to rich + stdout by default")
```

---

## Suppress by default with `fallback_handler={HandlerType.Unknown}`

This feature takes heavy advantage of the `extra` feature of Python logging. Please read the documentation on how `extra` is used, [found here](../../../dev/explanation/).

You can make newly-added handlers opt-in only by setting fallback handlers to `HandlerType.Unknown`. This means records without explicit `extra["handlers"]` will not be emitted by those handlers.

```python
from daqpytools.logging import HandlerType, add_handler, get_daq_logger

log = get_daq_logger("fallback_demo", rich_handler=True, stream_handlers=False)

# Add stderr handler, but suppress it by default
add_handler(
    log,
    HandlerType.Lstderr,
    use_parent_handlers=True,
    fallback_handler={HandlerType.Unknown},
)

log.critical("Only rich by default")

# Explicitly target stderr when needed
log.critical(
    "Rich + stderr when explicitly requested",
    extra={"handlers": [HandlerType.Rich, HandlerType.Lstderr]},
)
```

For a more in depth discussion on this feature, please see the development docs. 

---

## Passing arguments to handlers and filters via `**kwargs`

Advanced setup functions accept extra keyword arguments and forward them to the relevant handler/filter factories.

- `get_daq_logger(..., **extras)` forwards extras to handler/filter construction.
- `add_handler(..., **extras)` forwards extras to that handler factory.

Common examples:

- file handler: `path="mylog.log"`
- ERS Kafka handler: `ers_kafka_session=...`
- throttle filter: `initial_threshold=...`, `time_limit=...`
- rich handler: `width=...`

Example with explicit extras:

```python
from daqpytools.logging import HandlerType, add_handler, get_daq_logger

log = get_daq_logger("extras_demo", rich_handler=False)

# Pass file-specific kwargs to file handler
add_handler(
    log,
    HandlerType.File,
    use_parent_handlers=True,
    path="extras_demo.log",
)

# Pass rich-specific kwargs to rich handler
add_handler(
    log,
    HandlerType.Rich,
    use_parent_handlers=True,
    width=120,
)

# ERS-specific kwargs are supplied through setup/get APIs
# setup_daq_ers_logger(log, ers_kafka_session="session_tester")
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Emir Muhammad_

_Date: Wed Apr 15 15:41:46 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
