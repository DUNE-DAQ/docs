# DUNE Detectors Data Formats

This repository contains bitfields of detector raw data and utilities used to decode them. In general, each kind of detector data can be conveniently decoded via a class with the name of the form `<datatype>Frame` found in a public header file called `<datatype>Frame.hpp`, where values like timestamps and ADC values can be easily retrieved via getter functions. Additionally, for some kinds of data, Python utilities are available. 

For those who work on ProtoDUNE (otherwise skip this paragraph): this package is similar to the `dune-raw-data` package which contains overlay classes for ProtoDUNE datatypes. In fact, in some cases, the code is essentially cut-and-pasted over; e.g., the `anlTypes.hh` header from `dune-raw-data` which helps SSP data analyses has been copied into `SSPTypes.hpp`. 

Each section below describes the utilities available for different detectors. Links are provided to the code; be aware, however, that the code you're linked to is taken from the head of this package's `develop` branch and consequently may differ from the code you may be using. 

## WIB
[`WIBFrame.hpp`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/wib/WIBFrame.hpp)

The `WIBFrame` class contains a nested set of overlay classes and structs. `WIBFrame` includes [private instances](https://dune-daq-sw.readthedocs.io/en/latest/packages/styleguide/#58-access-control) of `WIBHeader` and an array of `ColdataBlock` structs, accessible via getter functions. Each `ColdataBlock` struct contains a [public instance](https://dune-daq-sw.readthedocs.io/en/latest/packages/styleguide/#58-access-control) of a `ColdataHeader` and a public array of `ColdataSegments`. 

Through these classes and structs it's possible to access the value of any channel/ADC combination in a WIB frame, as well as set these values. In the case of both `ColdataBlock` and its component `ColdataSegments`, only the channel and ADC numbers need to be provided; to do this directly with an instance of a `WIBFrame`, the `ColdataBlock` index needs to be provided as well. 

Other useful functions in `WIBFrame` include setters for the timestamp and WIB errors in its `WIBHeader` instance, as well as a streamer which allows developers to easily print the contents of the `WIBFrame` instance using the `<<` operator on the instance. 

## WIB2
[`WIB2Frame.hpp`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/wib2/WIB2Frame.hpp)

A `WIB2Frame` instance contains as members instances of the `WIB2Frame::Header` and `WIB2Frame::Trailer` structs as well as an array of ADC values. This reflects the definition of the WIB format given in https://edms.cern.ch/document/2088713/4. It also has getters and setters for ADC values, including options to select among U-channel, V-channel and X-channel ADCs when doing so. It's also possible to easily obtain the timestamp of the frame via `get_timestamp`. 

## DAPHNE
[`DAPHNEFrame.hpp`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/daphne/DAPHNEFrame.hpp)

`DAPHNEFrame` is used for working with data produced by DAPHNE front end boards (DAPHNE = Detector electronics for Acquiring PHotons from Neutrinos). Technical details on DAPHNE can be found in https://edms.cern.ch/document/2088726/3. The structure of `DAPHNEFrame` is similar in some ways to the structure of `WIB2Frame`: it consists of an instance of a `DAPHNEFrame::Header` and `DAPHNEFrame::Trailer` struct, as well as an array of ADCs. It also contains a `get_timestamp` function as well as getters and setters for ADC values. 

## SSP
[`SSPTypes.hpp`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/ssp/SSPTypes.hpp)

This header contains `enum`s describing commands to control SSPs as well as statuses returned by SSPs. It also contains a set of structs, including `EventHeader` (overlay class for the header of SSP data), `CtrlHeader` (overlay class for the header of command data sent to SSPs), `CtrlPacket` (a `CtrlHeader` instance plus a data payload), and `MillisliceHeader` (describing the time window and trigger info of SSP data). 

## PACMAN

[`PACMANFrame.hpp`](https://github.com/DUNE-DAQ/detdataformats/blob/develop/include/detdataformats/pacman/PACMANFrame.hpp)

`PACMANFrame` contains `enum`s describing message types, word types, and packet types. It also contains bitfields representing LArPix data packets and PACMAN data words. 





-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Wed Nov 24 15:46:42 2021 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/detdataformats/issues](https://github.com/DUNE-DAQ/detdataformats/issues)_
</font>
