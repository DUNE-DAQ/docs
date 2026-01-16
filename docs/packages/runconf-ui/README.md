# Shifter Interface

## Overview
The Shifter-Interface is a TUI designed to be used to enable/disable elements of the detector. Currently it can interface with 3 elements

- **Detector Subsystems**: These are large scale elements of the detector possibly consisting of many components, for example the NP04 APAs.
- **Dataflow Applications**: Straightforwardly, these are simply the applications which control dataflow from the detector
- **Triggers**: Specifically triggers controlled by detector components i.e. TPG in ReadoutApplications.

## Install
The TUI is installable with a daq enviroment through with pip
```bash
pip install [-e] .
```

## Initialisation
The interface is initialised with 
```bash
runconf-shifter-ui
```
optionally the following CLI flags exist for custom paths:
```
  -a, --apparatus                 Set the detector apparatus i.e. NP02/NP04
  
  -s, --shifter-interface-config  Set default yaml config for this interface
  
  -d, --daq-config-directory      Where do you want to download configs
                                  to 

  --session-name                  Name of daq session
  
  --base-url                      Base URL for the interface, not used for
                                  local operation
  
  --operation-url                 Operation URL for the interface, not used
                                  for local operation
  
  --debug                         Set the debug log level

  -l, --local-config              Use local config files instead of
                                  downloading. Should be a path to wherever your local configs are kept

  --help                          Show help
```

The default settings can be found in `src/cider/configuration/np02_configuration.yml` and can be set either directly or via environment variable. Specifying an option in the CLI overrides the yaml default.
 
## Usage
To get started pick a version of the daq configuration from the left hand side drop down menu. If only one version/directory is available this menu will be disabled & and that version automatically picked. Next pick your configuration from the right hand menu, again this will be disabled and automated if only one configuration file is available.

Currently there are 3 categories of objects that can be enabled or disabled:
- **Detector subsystems**: For example the APAs, PDS, etc.
- **The Trigger System**: Triggers to enable/disable including trigger primitive generation
- **Dataflow applications**: Objects that control dataflow

To disable/enable items simply press the buttons on the left side of the screen. Each set of objects is given its own tab.
In addition, we provide 3 views of the detector configuration, although this is mostly intended for expert use.
- **Configuration view**: View a tree describing detector configuration
- **Detector system view**: Summary of detector subsystems which are enabled/disabled
- **Trigger View**: A summary of triggers/trigger objects which are enabled/disabled 

Once you have made the desired changes, press the "Create" button to save the configuration. By default the current configuration is saved in the <RUN FOLDER>/current_config directory.
Older configurations are automatically moved to <RUN FOLDER>/old_configs/run_<DATE> when a new configuration is saved. 

If you are unhappy with changes + want to revert to the original configuration, press the "Reset" button.

Finally to quit the interface, press the "create" button. The configuration can be run in drunc using the command provided after quitting.

If you have any questions, please contact the DAQ shifter on duty. Enjoy your shift!

## Configuring the Interface
Specific instructions for setting up the interface YAMLs can be found [here](https://github.com/DUNE-DAQ/runconf-ui/blob/develop/docs/runconf_ui_config.md).

## Instructions for Developers
Developer instruction can be found [here](https://github.com/DUNE-DAQ/runconf-ui/blob/develop/docs/dev_instructions.md).


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Henry Wallace_

_Date: Thu Jan 15 11:00:12 2026 +0000_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/runconf-ui/issues](https://github.com/DUNE-DAQ/runconf-ui/issues)_
</font>
