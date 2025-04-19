# Instructions for Developers
## Overview
This is a rough guide for de-mistifying the runconf_ui interface! Note, if you just want to setup a new detector instructions are saved [here](shttps://github.com/DUNE-DAQ/runconf-ui/blob/develop/docs/shifter_interface_yaml.md). 

For specific questions about textual, please check [here](https://textual.textualize.io). 

## runconf_ui structure
`runconf_ui` is split into 5 types of object


1. apps: Full textual applications


2. interfaces: These are interfaces with DAQ libraries


3. screens: Specific textual screens accessible to DAQ applications


4. utils: Internal utility functions


6. Widgets: Internal textual widgets

## Interfaces
The interfaces for `runconf_ui` are split into 3:


1. `DaqConfigurationWrapper`: Very thin wrapper around the `conffwk` configuration object, currently just adds some checks to file opening but can in principal be extended much further.


2. `ShifterInterfaceState` [stored in `application_controller.py`]. This object stores state information about the interface, this allows information to be passed between objects in a TUI implementation independent way.


3. `Actions`: This will be explained shortly in a second, but broadly `actions` take a configuration and perform an operation. 


4. `Workflows`: More complicated actions, often requiring many steps

### Actions
A `runconf_ui` action is defined as an operation on a configuration. All actions inherit from `ActionInterface`, a very simple object does two things:


1. Takes a DAQ configuration 


2. Defines an operation on the object

To see this more explicity we can consider our `CopyDalAction`

```python
class CopyDalAction(ActionInterface):
    def action(self, dal):
        """
        Copy object in configuration
        """
        self._daq_configuration.add_dal(dal)
        return dal
```

Here we inherit from the interface and hence only need to define the copy DAL functionality. This decoupling of configuration and "actions on a configuration" means that only these objects need be changed if we implement major changes to `conffwk`.

## Screens
Screens are simply what the user actually sees when they boot the app. For `shifter-view`, 3 screens are defined


1. `ShifterViewScreen`: The main screen in the interface.


2. `QuitScreen`: PopUp screen shown when create and quit are pressed


3. `HelpScreen`: Help screen shown when help is pressed.

## Widgets
Textual provides functionality to add individual TUI components as widgets. For the interface we use widgets for buttons, file I/O panels and more!

## Utils
The utils folder is a nebulous collection of utility objects used in runconf_ui. Broadly these are splt into


1. Tools for interacting with the DAQ configuration management


2. Tools for interacting with the DAQ configuration i.e. making configuration trees


3. Tools for handling files in general, for example saving and cleaning files


4. Tools for opening and generating objects from the shifter configuration YAMLs.



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Henry Wallace_

_Date: Mon Apr 7 15:59:12 2025 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/runconf-ui/issues](https://github.com/DUNE-DAQ/runconf-ui/issues)_
</font>
