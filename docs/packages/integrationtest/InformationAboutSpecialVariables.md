# Special variables that are used by the integrationtest infrastructure

21-Sep-2026, Kurt Biery

## Introduction

In the Pytest files that we write (our integtests), there are several special variables that are used to communication information about the desired conditions of the testing to the `integrationtest` infrastructure.  This information includes things such as configuration parameters and run control commands.

This document describes the special variables that are currently available and how they can, and should, be used.

### Computer resource validation parameters

This is communicated by the `resource_validator` special variable.  It should point to an instance of the `ResourceValidator` class.  This class is defined in [integrationtest/src/integrationtest/resource_validation.py](https://github.com/DUNE-DAQ/integrationtest/blob/develop/src/integrationtest/resource_validation.py).

(More details coming soon.)

### Integrationtest and DAQ system configuration parameters

This is communicated by the `confgen_arguments` special variable.

(More details coming soon.)

### Run control process manager type(s)

This is communicated by the `process_manager_choices` special variable.

(More details coming soon.)

### Run control commands or full DAQ session ingredients

These are communicated either by the `dunerc_command_list` or the `daq_session_ingredients` special variable.  Only one of these two variables should be specified in a single integtest file, but if both of them happen to be specified in the same integtest, the `daq_session_ingredients` takes precedence.

The purposes of these two variables are similar - both provide commands that should be run by one or more run control applications - but the `daq_session_ingredients` variable is more powerful in that it allows users to specify one or more applications that should be run, instead of simply using the `drunc-unified-shell`.

Information about `dunerc_command_list`:


* this is the variable that has been used historically, and many of our existing integtests use it.

* it is expected to contain a Python list of the commands (strings) that are passed to run control in "batch" mode

    * some examples:

        * `dunerc_command_list = ("boot conf start --run-number 101 wait 1 enable-triggers wait ".split() + [str(run_duration)] + "disable-triggers wait 2 drain-dataflow wait 2 stop-trigger-sources stop scrap terminate".split())`

        * `dunerc_command_list = ["boot", "conf", "start", "--run-number", "101", "wait", str(1), "enable-triggers", "wait", str(20), "disable-triggers", "stop-run", "shutdown"]`

* in addition to containing a single list of commands (as shown above), this variable can contain a dictionary of one or more lists of commands.  With this functionality, multiple DAQ sessions with different sets of commands can be run from an single integtest.

    * here is an example of this type declaration:

        * `dunerc_command_list = {"DAQ_Session_1": ["boot", "conf", "start", "--run-number", "101", "wait", str(1), "enable-triggers", "wait", str(20), "disable-triggers", "stop-run", "shutdown"], "DAQ Session 2": ["boot", "conf", "start", "--run-number", "101", "wait", str(3), "enable-triggers", "wait", str(20), "disable-triggers", "stop-run", "scrap", "terminate"]}`

Information about `daq_session_ingredients`:

* this variable was recently introduced so that developers of integtests can specify multiple control applications to be run in a given (integtest) DAQ session

* at the moment, this variable needs to contain a dictionary with one or more elements, and each element should contain a string key (with a word or phrase that describes the DAQ session) and an instance of the `DAQSessionIngredients` class as the value.  The `DAQSessionIngredients` class is defined in [integrationtest/src/integrationtest/data_classes.py](https://github.com/DUNE-DAQ/integrationtest/blob/0fe60d9b1c1aa697ec9524c4aaf1507aaa3c6b2a/src/integrationtest/data_classes.py#L139).

* the [basic_multiapp_test.py](https://github.com/DUNE-DAQ/drunc/blob/kbiery/multi_ctrl_proc_support/src/drunc/integtest/basic_multiapp_test.py) regression test in the `drunc` repo has an example of specifying three applications to be run in the DAQ session and specifying commands that are sent to two of those applications.

    * For reference, the relevant lines from `basic_multiapp_test.py` are copied below.

* in these instructions, I have tried to use the word "application" to mean a C++ program or a Python script that has been developed to perform one or more functions.  And, I have tried to use the word "process" to mean an instance of an application that is running as part of a DAQ session.  Apologies if this model is not strictly used everywhere.

* the `DAQSessionIngredients` class has data members that allow developers to specify the applications that should be run and the commands that should be sent to the processes.  In this class, applications are represented by instances of the `DAQControlApplication` class and commands are listed in instances of the `DAQCommandSet` class.  The `DAQCommandSet` has a field that specifies the process that we want to send the commands to.

    * reference information:

```python
@dataclass
class DAQSessionIngredients:
    applications: list[DAQControlApplication]
    commands: list[DAQCommandSet]

@dataclass
class DAQControlApplication:
    alias: str  # a short-hand name for the process that is started
    startup_strings: list[str]  # the elements of the command string that should be used to start the application
    startup_wait_params: ConsoleOutputWaitParameters = None

@dataclass
class DAQCommandSet:
    target: str  # the name of the process that should receive the commands
    command_list: list[str]  # the list of commands, e.g. ["boot", "conf"]
    wait_params: ConsoleOutputWaitParameters = None
    wait_for_command_completion: bool = True

@dataclass
class ConsoleOutputWaitParameters:
    timeout_waiting_for_first_msg: int = 2  # seconds
    wait_time_after_last_msg: int = 2  # seconds

@dataclass
class KeyPhraseWaitParameters(ConsoleOutputWaitParameters):
    timeout_waiting_for_first_msg: int = 30  # seconds
    wait_time_after_last_msg: int = 30  # seconds
    search_phrase: str = None

@dataclass
class EchoCommandWaitParameters(ConsoleOutputWaitParameters):
    timeout_waiting_for_first_msg: int = 999999  # seconds
    wait_time_after_last_msg: int = 999999  # seconds
    search_phrase: str = "*** COMMAND HAS COMPLETED ***"

@dataclass
class ProcessExitWaitParameters(ConsoleOutputWaitParameters):
    timeout_waiting_for_first_msg: int = 30  # seconds
    wait_time_after_last_msg: int = 30  # seconds
    process: asyncio.subprocess.Process = None
```


* Here is some additional information about `ConsoleOutputWaitParameters` and its child classes:

    * the commands that are specified in a `DAQCommandSet` are sent individually to the target process without any delay between them.  So, we typically send all of the commands in the set in a fraction of a second, while the target process could take tens of seconds to execute all of them.

    * when there is only one control process in an integtest, this rapid-fire approach may be all that we need, because a single process handles the throttling of the commands, running them one after another.  However, when there are multiple control processes in an integtest, we may want to send a set of commands to Process1, wait for those to finish, and only then send a set of commands to Process2.  This demonstrates a need to allow an `integrationtest` developer to specify whether they want the `integrationtest` infrastructure to wait for each command set to finish before moving on to the next set of commands, and if so, what style of waiting they would like be used.  This is the motivation for the `ConsoleOutputWaitParameters` class and its child classes.

        * of course, there are also situations in which we want to wait for all of the requested commands to finish running even when there is only one control process in the integtest.  For example, we will likely want to allow a single process to finish executing all of the requested commands before the `integrationtest` infrastructure starts shutting down that process.

    * the currently-supported wait styles are _console-output_, _echo-command_, _key-phrase_, and _process-exit_.

    * the _console-output_ wait style simply waits for configured amounts of time for console output to start and then stop.  The idea here is to use the console output as an indicator of activity, and when the console output stops, we presume that activity related to the requested command(s) has stopped.

    * the _echo-command_ wait style makes use of the `echo` command that is available in some of our control applications to clearly identify when a set of commands has finished.  So, if a user specifies a command set that contains commands `['boot', 'conf']` and has a wait style of _echo-command_, the `integrationtest` infrastructure appends an `echo` command with a special string to the set, i.e. `['boot', 'conf', 'echo "<special string>"']`.  When the `integrationtest` infrastructure sees that special string in the output of the target process, it knows that the command set has finished.

        * this wait style is quite robust since we know that all of the commands before the `echo` command have been run when the `echo` results are seen in the process output.  However, some applications don't provide `echo` functionality.  In the unlikely even that this wait style is requested from an application type that doesn't support it, the `integrationtest` infrastructure will switch to a _console-output_ wait style with timeout values taken from the _key-phrase_ defaults.

        * this wait style inherits from the _console-output_ wait style, so, in principle, it will time out if the special echo string is not seen in the console output.  However, the default values for the console output timeouts are set very long so that we don't accidentally time out too soon (for example, if an integtest includes a 300-second data-taking run).  Of course, integtest developers can choose smaller timeout values for special situations.

    * the _key-phrase_ wait style looks for a specific phrase in the console output, and the `integrationtest` infrastructure stops waiting when it sees that phrase.

        * if the phrase is not found before the console output times out based on the timeout values in the `KeyPhraseWaitParameters` instance, then the infrastructure will stop waiting and print out a warning message.

    * the _process-exit_ wait style is intended to be used with "exit" commands.  The idea here is to wait for console output to stop and the process to exit (within a configurable timeout).

        * if, for some reason, the process does not exit in response to the 'exit' command, the timeout values in the ProcessExitWaitParameters object are used to stop waiting in a reasonable amount of time.

* There are several strings that are dynamically determined by the `integrationtest` infrastructure that we may want to include in the `startup_strings` field in our `DAQControlApplication` declarations.  To take this into account, placeholder strings have been defined.  These placeholder strings can be used in `DAQControlApplication` declarations and the `integrationtest` infrastructure will substitute the appropriate value at runtime.  The placeholders that are currently available are the following:

    * `<proc_mgr_choice>` - the process manager type that should be used in the DAQ session

        * recall that the `integrationtest` infrastructure has support for user-specified (dynamic) process manager types.  If we don't want to make use of that functionality, we can hard-code the process manager type in our `DAQControlApplication.startup_strings`.  Of course, that reduces flexibility, but there may be cases where it would make sense.

    * `<config_data_file>` - the configuration data file that the infrastructure has created for the integtest

        * this placeholder string should always be used since the `integrationtest` infrastructure creates a new, temporary config data file for each running of an integtest

    * `<config_session_name>` - the name of the configuration session that should be used for the DAQ session

        * this could be hard-coded, but it is safer to let it get filled in dynamically

    * `<daq_session_name>` - the name that should be used to identify the DAQ session

        * this placeholder can be used, or the name of the DAQ session could be hard-coded in the `startup_strings`

* when an integration test is run with verbosity level of 4 or greater, the command lines that are used to start the applications are printed on the console, and this output can be used to check if the desired substitutions were made

Here is a snippet of code from the `basic_multapp_test.py` that shows how the `DAQSessionIngredients` are constructed in that integtest:

```python
# The commands to run in dunerc and the process manager shell
dunerc_commands_1 = (
    "boot conf start --run-number 101 wait 1".split()
)
dunerc_commands_2 = (
    "enable-triggers wait".split() + [str(run_duration)] + ["disable-triggers"]
)
dunerc_commands_3 = (
    "drain-dataflow stop-trigger-sources stop wait 2 scrap terminate".split()
)
pmshell_command = ["ps"]

# Find a free network port to use for the process manager
pm_port = find_free_port(50020, 52000)

# The command lines that should be used to start the applications
procmsg_startup_commands = ["drunc-process-manager", "<proc_mgr_choice>", str(pm_port)]
pmapp = idc.DAQControlApplication("pm", procmsg_startup_commands,
                                       idc.KeyPhraseWaitParameters(search_phrase="communicating through",
                                                                   timeout_waiting_for_first_msg=5,
                                                                   wait_time_after_last_msg=5))

pmshell_startup_commands = ["drunc-process-manager-shell", f"grpc://localhost:{pm_port}"]
pmshellapp = idc.DAQControlApplication("pmshell", pmshell_startup_commands,
                                       idc.KeyPhraseWaitParameters(search_phrase="Ready"))

drunc_startup_commands = ["drunc-unified-shell", f"grpc://localhost:{pm_port}",
                          "<config_data_file>", "<config_session_name>", "<daq_session_name>"]
druncapp = idc.DAQControlApplication("drunc", drunc_startup_commands,
                                     idc.KeyPhraseWaitParameters(search_phrase="unified_shell ready"))

# Packaging up the commands into DAQCommandSets
cmd_set_1 = idc.DAQCommandSet("drunc", dunerc_commands_1, idc.EchoCommandWaitParameters())
cmd_set_2 = idc.DAQCommandSet("pmshell", pmshell_command, wait_for_command_completion=False)
cmd_set_3 = idc.DAQCommandSet("drunc", dunerc_commands_2, idc.EchoCommandWaitParameters())
cmd_set_4 = idc.DAQCommandSet("pmshell", pmshell_command, idc.KeyPhraseWaitParameters(search_phrase="mlt"))
cmd_set_5 = idc.DAQCommandSet("drunc", dunerc_commands_3, idc.EchoCommandWaitParameters())

# Putting everything together into a DAQSessionIngredients object
app_list = [ pmapp, pmshellapp, druncapp ]
cmd_set_list = [ cmd_set_1, cmd_set_2, cmd_set_3, cmd_set_4, cmd_set_5 ]
dsi = idc.DAQSessionIngredients(app_list, cmd_set_list)

# Declare the special variable that tells the integrationtest infrastructure what we want to run
daq_session_ingredients = {"MultiRCAppSession": dsi}
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Kurt Biery_

_Date: Tue Sep 22 14:12:42 2026 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/integrationtest/issues](https://github.com/DUNE-DAQ/integrationtest/issues)_
</font>
