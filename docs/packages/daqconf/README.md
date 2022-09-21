# daqconf

This repository contains tools for generating DAQ system configurations, the [`daqconf_multiru_gen` script](https://github.com/DUNE-DAQ/daqconf/blob/develop/scripts/daqconf_multiru_gen) ("DAQ configuration, multiple readout unit generator"). It generates DAQ system configurations with different characteristics based on command-line parameters and configuration files that are given to it. 

The focus of this documentation is on providing instructions for using the tools and running sample DAQ systems. If you're starting out, take a look at:

[Instructions for casual or first-time users](InstructionsForCasualUsers.md)

and for a slightly more in-depth look into how to generate configurations for a DAQ system, take a look at:

[Configuration options for casual or first-time users](ConfigurationsForCasualUsers.md)

Traditionally multiple command line options were passed to `daqconf_multiru_gen` in order to control how it generated configurations. However, for the `dunedaq-v3.2.0` release (September 2022) we're switching to passing a single JSON file whose contents contain the information needed to control `daqconf_multiru_gen`. For `daqconf_multiru_gen` users who want to learn about how to make the switch to this new approach, take a look at [these migration instructions](MigratingToNewConfgen.md).

Finally, here's nice visual representation of the type of DAQ system which can be configured: 


<img width="697" alt="v3 0 0_screenshot_08Jun2022" src="https://user-images.githubusercontent.com/36311946/172657352-20db6334-13b6-4dd5-9e99-ef989ad6a4af.png">


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Tue Sep 20 14:27:28 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
