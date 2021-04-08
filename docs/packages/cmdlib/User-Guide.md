# User Guide
## Commands
Commands are JSON objects. They have a signature of having an `id` string element, and a `data` object which is a user defined custom parameter list. For an example, please have a look on the `-job.json` files in appfwk. For better names, these field might be renamed in the future. This is how the init command looks like in order to create a fake data producer and a consumer modules, connected by a queue:
```
{
        "id": "init",
        "data": {
            "modules": [
                {
                    "data": {
                        "qinfos": [
                            {
                                "dir": "output",
                                "inst": "hose",
                                "name": "output"
                            }
                        ]
                    },
                    "inst": "fdp",
                    "plugin": "FakeDataProducerDAQModule"
                },
                {
                    "data": {
                        "qinfos": [
                            {
                                "dir": "input",
                                "inst": "hose",
                                "name": "input"
                            }
                        ]
                    },
                    "inst": "fdc",
                    "plugin": "FakeDataConsumerDAQModule"
                }
            ],
            "queues": [
                {
                    "capacity": 10,
                    "inst": "hose",
                    "kind": "StdDeQueue"
                }
            ]
        }
    }
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

    daq_application -c stdin://sourcecode/appfwk/schema/fdpc-job.json

![Demo](https://cernbox.cern.ch/index.php/s/BxvvU0PlPuyHjla/download)
-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu Apr 8 09:37:47 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/cmdlib/issues](https://github.com/DUNE-DAQ/cmdlib/issues)_
</font>
