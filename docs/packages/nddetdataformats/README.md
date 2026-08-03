# DUNE Near Detector Data Formats

This repository contains bitfields of near detector raw data and utilities used to decode them. For more on this concept, see also [the detdataformats documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/detdataformats/). Each section below describes the utilities available for different parts of the near detector. Links are provided to the code; be aware, however, that the code you're linked to is taken from the head of this package's `develop` branch and consequently may differ from the code you may be using. 

## PACMAN

[`PACMANFrame.hpp`](https://github.com/DUNE-DAQ/nddetdataformats/blob/develop/include/nddetdataformats/PACMANFrame.hpp)

`PACMANFrame` contains `enum`s describing message types, word types, and packet types. It also contains bitfields representing LArPix data packets and PACMAN data words. 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Mon Apr 24 10:15:07 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/nddetdataformats/issues](https://github.com/DUNE-DAQ/nddetdataformats/issues)_
</font>
