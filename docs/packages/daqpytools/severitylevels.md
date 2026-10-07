# Severity levels

Logging messages are grouped by severity so you can decide what should be shown, routed, or ignored.
The names below match the standard Python logging levels used by daqpytools.
For more information on how these are used in logging, see the [concepts and explanation page](./explanation.md).

## Overview

| Level | Typical meaning | When to use it | Example |
|---|---|---|---|
| `DEBUG` | The most detailed diagnostic output. | Use when you need to trace control flow, inspect state, or confirm that everything is wired correctly. Useful for troubleshooting. | A health check is running and you want to confirm the retry behavior. `Health check: attempt 5 at 4s elapsed.` |
| `INFO` | Normal progress information. | Use for messages that help a user understand what command or service is doing without adding noise. | A process manager has started and you want to report normal progress. `Starting process manager for the session.` |
| `WARNING` | Something unexpected happened, but execution can continue. | Use when a fallback is taken, input looks suspicious, or behavior is not ideal but still recoverable. | A command still works, but the old name is being phased out. `Retract partition is deprecated. Please use retract-session instead.` |
| `ERROR` | A problem occurred that must be fixed for the current operation to succeed. | Use when a command failed, a configuration is invalid, or a required dependency is missing. | Drunc not working due to some http variables not being set. `This can happen if you have the webproxy enabled at CERN. Ensure 'http_proxy' and equivalent aren't set` |
| `CRITICAL` | An unrecoverable failure. | Use when the process or running instance cannot continue safely. | An application has died unexpectedly. `Process [uuid] has died with a return code [code].` |

The DUNE-DAQ organization has developed primarily using C++, which currently forms the majority of the organization's stack. As such, the definitions of the log levels and how they are treated have been chosen to resemble the C++ standard as closely as possible, as defined in the C++-specific [`logging`](https://dune-daq-sw.readthedocs.io/en/latest/packages/logging/) and [ERS](https://dune-daq-sw.readthedocs.io/en/latest/packages/logging/ers-conventions/#issue-inheritance) documentation. 

## How various severity levels are treated
In integration testing environments, the presence of warning messages in output logs will cause a test to fail. This is due to the fact that in this scenario, we have the most control over the environment and compute resources available, and it is expected that the defined integration tests fully conform to the unit test selected from the integrationtest repo. Messages more severe, such as error, are treated as failures as well.

In production testing environments, there are many more variables that cannot be accounted for, including the dependency on hardware status and use and supporting more users concurrently developing and running tests within the cluster, which are beyond the scope of the DAQ developer. Some common warning messages that are caused by the environment and configuration include:
 - `Dropped packet error counts X`
 - `Trigger is inhibited in run X`

Because of these uncontrollable environment parameters, some warning messages are not cause tests to fail, but it is critical to consult the relevant working group experts to validate if you are unsure. Messages more severe than warning should be considered as failures regardless of their content. 

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: PawelPlesniak_

_Date: Tue Jul 7 17:11:23 2026 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqpytools/issues](https://github.com/DUNE-DAQ/daqpytools/issues)_
</font>
