# How to add daqpytools logging to an existing Python package

This page is a practical migration checklist for packages that already use Python logging and want to standardise on `daqpytools.logging`.

For design rationale and architecture, read [Best practices](./best-practices.md) and [Concepts & explanation](../explanation.md).

---

## Migration checklist

## 1) Choose a pseudo-root logger name

Pick one stable package-level prefix, for example:

- `drunc`
- `mypkg`

All application/module loggers should live under this namespace:

- `mypkg.cli`
- `mypkg.worker`
- `mypkg.worker.io`

## 2) Initialise the pseudo-root once, early

Call `setup_root_logger` at process startup (entrypoint/main), before creating child loggers.

```python
from daqpytools.logging import setup_root_logger

setup_root_logger("mypkg", log_level="INFO")
```

The pseudo-root should be a clean inheritance anchor and should not be configured with arbitrary ad-hoc handlers.

## 3) Create a package helper to enforce naming/inheritance

Define a small helper so all code consistently gets namespaced loggers.

```python
from daqpytools.logging import get_daq_logger

PSEUDO_ROOT = "mypkg"


def get_logger(name: str, **kwargs):
	full_name = f"{PSEUDO_ROOT}.{name}" if name else PSEUDO_ROOT
	return get_daq_logger(logger_name=full_name, **kwargs)
```

This avoids accidental logger-name drift and makes traceability much better.

## 4) Configure handlers at parent/package boundaries

Attach default handlers where they make sense architecturally (often package/module entry points), not everywhere.

```python
from mypkg.logging_utils import get_logger

# Example package-level logger with default rich output
get_logger("utils", rich_handler=True, log_level="INFO")
```

Child loggers then inherit handlers naturally.

## 5) Migrate module files to child loggers

In each module, request a child logger and use it directly.

```python
from mypkg.logging_utils import get_logger

log = get_logger("worker.io")


def run() -> None:
	log.info("Worker started")
```

Prefer inheritance over repeatedly reconfiguring handlers.

## 6) Replace old logging patterns safely

During migration, remove or phase out patterns that interfere with shared configuration:

- `logging.basicConfig(...)`
- direct root-logger mutation
- ad-hoc per-file handler wiring that duplicates inherited setup

Incremental migration is fine; it does not need to be a flag day.

## 7) Add ERS support (optional)

If your application uses ERS routing:



1. Create/reuse your package logger


2. Call `setup_daq_ers_logger(...)`


3. Ensure ERS environment variables are set before logger initialisation

```python
from daqpytools.logging import get_daq_logger, setup_daq_ers_logger

log = get_daq_logger("mypkg.app", rich_handler=True)
setup_daq_ers_logger(log, ers_kafka_session="my-session", ers_app_name="mypkg")
```

See [How to configure ERS](./configure-ers.md) for details.

---

## Suggested rollout plan



1. Add the helper and pseudo-root setup.


2. Convert one subsystem to namespaced child loggers.


3. Validate output/routing and inheritance.


4. Convert remaining modules.


5. Remove legacy logging configuration paths.

---

## Quick validation checklist

- Pseudo-root initialised once at startup
- No `logging.basicConfig` in runtime paths
- Package helper used consistently
- Parent handlers configured once, child loggers mostly inherited
- Optional ERS setup performed after env vars are available

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Emir Muhammad_

_Date: Tue Apr 14 18:40:50 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
