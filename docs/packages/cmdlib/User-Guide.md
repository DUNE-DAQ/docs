# User Guide
## Commands
Commands are JSON objects. They have a signature of having an `id` string element, the FSM entry and resulting states, and a `data` object which is a user defined custom parameter list. For an example, please have a look on the `cmd.json` file in cmdlib/data. For better names, these field might be renamed in the future. This is how the start command looks like:
```
    {
        "data": {
            "modules": [
                {
                    "data": {
                        "run": 42,
                        "disable_data_storage": false,
                        "trigger_rate": 1.5
                    },
                    "match": ""
                }
            ]
        },
        "id": "start",
        "entry_state": "CONFIGURED",
        "exit_state": "READY"

    },

```

## CommandedObject
Commanded objects are meant to implement the `CommandedObject` interface from this library. They need to implement a single function, which is `execute`, and it's responsible to process the command objects. One really good example to follow, is the `DAQModuleManager` from the `appfwk`. The mockup of the implementation is as follows:
```
void
DAQModuleManager::execute( const dataobj_t& cmd_data ) {

    auto cmd = cmd_data.get<cmd::Command>();
    ERS_INFO("Command id:"<< cmd.id);
    ...
    dispatch_for_modules(cmd.id, cmd.data);
}
```

## CommandFacility
This base class is responsible to provide a fixed behavior of command handling, but still requiring to implement a `command_callback` and `completion_callback` function implemented. The command callback helps to decouple the commanded object and the transport layer based implementation from the actual background mechanism, that queues in the commands in a completion queue for asynchronous execution. When a command is executed on the commanded object, the facility implementation's completion callback is called. Such mechanism provides consistency and transparency across every implementation.

With the help of `cetlib` plugin factory library, this makes it transparent to implement different solutions that rely on alternative protocols to transfer commands. For other examples, please have a look at the `stdinCommandFacility` that is shipped with this package, and the HTTP based `restCommandFacility` from the `restcmd` package.

### Using the stdinCommandFacility
There is a really simple and basic implementation that comes with the package.
The stdinCommandFacility reads the available commands from a file, then one can
execute these command by typing their IDs on stdin:

    daq_application -c stdin://${CMDLIB_SHARE}/config/cmd.json

![Demo](https://cernbox.cern.ch/index.php/s/BxvvU0PlPuyHjla/download)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Giovanna Lehmann Miotto_

_Date: Thu Jul 14 18:18:42 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/cmdlib/issues](https://github.com/DUNE-DAQ/cmdlib/issues)_
</font>
