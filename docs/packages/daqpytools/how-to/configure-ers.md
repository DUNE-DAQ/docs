# How to configure ERS handlers

This page covers how to attach and use ERS (error reporting system) handlers on a logger.

For background on ERS streams and routing, see [Concepts](../explanation.md). For the `LogHandlerConf` routing API, see [Routing messages to specific handlers](./route-messages.md). For the definition of the handler itself as well as how it can be used, see [How to use handlers and filters](../../../dev/explanation/).

---

## Configuring ERS handlers onto a new logger (by construction)

Use the `ers_kafka_session` variable to put in the relevant session name in `get_daq_logger`. There are several attributes that you can use to customise the ERS handler as well, such as changing the ERS application name as displayed on the ERS dashboards, exampled below. Please see the [API reference](../../../APIref/handlers/protobufstream/) for full details on what can be passed in.  

```python
    from daqpytools.logging import get_daq_logger, 
    main_logger: logging.Logger = get_daq_logger(
        logger_name="logger_name",
        log_level="INFO",
        use_parent_handlers=True,
        ers_kafka_session="session_name,
        ers_app_name="Custom App Name", # Can be none!
    )
```

## Configuring ERS handlers on an existing logger

Use `setup_daq_ers_logger` to attach ERS-derived handlers to an existing logger based on environment configuration.

```python
from daqpytools.logging import LogHandlerConf, get_daq_logger, setup_daq_ers_logger

log = get_daq_logger(
    logger_name="ers_logger",
    rich_handler=True,
    stream_handlers=False,
)

# Attach ERS-derived handlers (lstdout, protobufstream) to this logger
setup_daq_ers_logger(log, ers_kafka_session="session_temp")

# Now use LogHandlerConf routing to target ERS handlers
ers_conf = LogHandlerConf(init_ers=True)
log.info("ERS Info routing", extra=ers_conf.ERS)
log.warning("ERS Warning routing", extra=ers_conf.ERS)
log.error("ERS Error routing", extra=ers_conf.ERS)
```

---

## ERS environment variables

ERS handlers are configured via environment variables. These are parsed automatically by daqpytools:

```
DUNEDAQ_ERS_ERROR="throttle,lstdout,protobufstream(monkafka.cern.ch:30092)"
DUNEDAQ_ERS_WARNING="..."
# etc.
```

These are parsed into `ERSPyLogHandlerConf` objects that hold the handler list and optional protobuf endpoint for each severity.

Remember that ERS environment variables need to exist at the point of ERS logger initialisation. See [best practices](./best-practices.md) for guidance on when to call `setup_daq_ers_logger`.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Emir Muhammad_

_Date: Wed Apr 15 15:41:46 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
