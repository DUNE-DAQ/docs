# tpglibs

The Trigger Primitive Generation (TPG) library is a separate module that processes raw waveform and returns the generated TPs.
Online, this is completed with an AVX2 implementation in order to keep up with the high data rate from the targeted detectors.
Offline, there are naive C++ and Python implementations that can be used to check the quality of the physics performance.

Each process in the engine is dedicated to completing one task and passing on to the next process.
In configuration, a user can decide the individual process configuration and the order to complete each process.
By the end, the engine body will take the result of the last process and check for any valid TPs.
TPs that are closed by some completion condition -- often having gone from above threshold to below threshold -- are finalized and shipped out.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Alejandro Oranday_

_Date: Mon Aug 19 07:26:50 2024 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/tpglibs/issues](https://github.com/DUNE-DAQ/tpglibs/issues)_
</font>
