# flxlibs - FELIX card software and utilities 
Appfwk DAQModules, utilities, and scripts for the FELIX readout card.

## Building and setting up the workarea
How to clone and build DUNE DAQ packages, including `flxlibs`, is covered in [the daq-buildtools instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/). You should follow these steps to set up your workarea that you can then use to run the following examples. You also need the `felix` external package that ships a build of a partial set of the ATLAS FELIX Software suite. This external is set up, if you followed the instructions correctly. 

## Disclaimer
The [Initial setup of FELIX page](Initial-setup-of-FELIX.md) doesn't mean to be a replacement for the official FELIX User Manual. For a much more detailed documentation, always refer to that appropriate RegisterMap version and device's user manual, that are found under the official [FELIX Project Webpage](https://atlas-project-felix.web.cern.ch/atlas-project-felix/).

## FELIX setup
Please ensure the following:



1. For the physical setup, please refer to the [Initial setup of FELIX](Initial-setup-of-FELIX.md).



2. For the card configuration, one needs compatible firmware and FELIX configuration sets. The list is under [FELIX Assets](FELIX-assets.md#compatibility_list).



3. Use the [Local driver](Local-driver.md) from the appropriate dunedaq release.



4. Configure the FELIX card, as explained in the [Enabling links and setting up the FELIX card](Enabling-links-and-setting-the-superchunk-factor.md) manual.



5. Load data into the emulator of the FELIX card based on the [Configuring the EMU](Configuring-the-EMU.md) manual.



6. Run basic tests explained in the [Basic tests](Basic-tests.md) manual to ensure that the card is properly set up.

## Examples
After successfully following the configuration instructions, you can try to run a test app that uses the FELIX.
First, create a configuration file if real front-end is connected to the card (enable all ADC links):

    python -m flxlibs.app_confgen -n 10 -m "0-4:0-4" felix-app.json
    
If the FELIX is on the emulator fanout and the internal emulator is loaded, apply also frame specific emulation for the DatalinkHanders to overwrite frame signatures (e.g.: timestamp, sequence number, etc.):

    python -m flxlibs.app_confgen -n 10 -m "0-4:0-4" -e felix-app.json

Then run it with:

    daq_application -c stdin://felix-app.json -n felix_10_links
    
You can now issue commands by typing their name and pressing enter. Use `init`, `conf` and then `start`. You should see periodic operational info as json printed out every 10 seconds. Verify that `rate_payloads_consumed` is around 166 for the links.



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: ShyamB97_

_Date: Thu Apr 28 11:13:35 2022 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/flxlibs/issues](https://github.com/DUNE-DAQ/flxlibs/issues)_
</font>
