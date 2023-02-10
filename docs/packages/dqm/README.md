# Data Quality Monitoring
Software and tools for data monitoring. This module processes data coming from
readout and dataflow and sends their output to kafka. The data can be displayed
in a web page, see [dqm-backend](https://github.com/DUNE-DAQ/dqm-backend)

## Building
How to clone and build DUNE DAQ packages, including dqm, is covered in [the
daq-buildtools
instructions](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/).

## How to run


* Nanorc configuration

For enabling the generation of dqm apps, one has to add `--enable-dqm` to the configuration generation, for example:

    daqconf_multiru_gen -c config.json --hardware-map-file HardwareMap.txt --enable-dqm conf_with_dqm

<!-- * Standalone configuration -->

<!-- To generate the standalone configuration, run -->

<!--     python sourcecode/dqm/python/dqm/fake_app_confgen.py -->

<!-- This will create a JSON file that can be used to run the `daq_application` -->

<!--     daq_application -c dqm.json -n dqm -->

<!-- The standalone configuration is as minimal as it can be. It runs readout, -->
<!-- obtaining the data from a file called `frames.bin` (the configuration assumes it -->
<!-- is located in the same directory that you are running from), and sends the -->
<!-- output of the algorithms to a kafka broker. -->

## Supported data streams


* Raw display: unchanged raw data. To modify it in the configuration use

      "raw_params": ["time", "num_frames"]

  Where `time` is the time in seconds between runs of the algorithm and
  `num_frames` is the number of frames used (only for DQM-RU apps). So if we
  want to get updates for the raw data stream every minute and get 100 frames
  then we would have

      "raw_params": ["60", "100"]


* STD: Standard deviation of the ADC distribution over a window of time. To modify use:

      "std_params": ["time", "num_frames"]


* RMS: RMS of the ADC distribution over a window of time, not to be confused
  with the standard deviation. To modify use:

      "rms_params": ["time", "num_frames"]


* Fourier transform: The fourier transform of ADC time series. Can be done for
  each channel or for each plane (by summing all the ADC time series and doing
  the fourier transform of the result). To modify use for each channel or for
  each plane respectively:

      "fourier_channel_params": ["time", "num_frames"],
      "fourier_plane_params": ["time", "num_frames"]


## Channel map
<!-- To use the horizontal drift channel map (default) with nanorc use `--dqm-cmap HD`, -->
<!-- to use the vertical drift channel map use `--dqm-cmap VD`. -->

## How to add an algorithm to DQM

## How to add a frotend type to DQM

## DQM internals

DQM has a set of algorithms implemented and configuration on how often to run
them. Once the time comes to run an algorithm, DQM will make a request to get
data back, and then will run the algorithm(s) and send the results to kafka. The
DQM apps can be of two types: the apps that communicate with readout (RU)
directly and the apps that communicate with dataflow (DF).

The DQM-RU apps request data by building a `TriggerDecision` and specifying the
start and end time of the window. This is dealt with internally, users specify
how many frames to request at configuration time and DQM builds the window with
information from the timing system. Each algorithm runs independently from each
other, which means that the window of data that each algorithm gets is
different. RU responds with a `TriggerRecord`, containing fragments with the
specified number of frames.

The DQM-DF apps request a `TriggerRecord` from DF in time intervals that can be
configured. DQM will make the request by building a `TRMonRequest` and then DF
will send a `TriggerRecord` as soon as it's available. The time between requests
and which algorithms will run on the received data can be configured, but in
this case DQM acts as a passive observer and gets what DF produces, so the
number of frames that DQM gets can't be configured. After the data is received,
the selected algorithms will run one after the other on the received data. To
avoid processing and / or sending huge amounts of data, there is a configurable
maximum number of frames that will be processed for fragments with lots of
frames (only the first N frames of each fragment will be used).

DQM keeps track of all the channels and planes by having an internal channel map
of the available channels. With the first data received, DQM will fill this
internal channel map so that data can be easily processed plane by plane, for
example.

DQM algorithms are implemented in two parts. The algorithms themselves are
implemented in `include/dqm/algs` and this is where the processing happens.
Then, a module that specifies what will be done with all the different channels
is implemented, specifying how the information is sent (for all channels? for
each plane?).

For the implementation, most functions that handle data are templated and the
template argument is the type of the data (for example,
`detdataformats::wib::WIBFrame`). Pointers to the data are extracted from the
fragments in the decoder, which also filters the type of fragment that DQM
supports (`kProtoWIB, kWIB`) Before starting the processing, there is a
preprocessing pipeline that will check the data, throw some errors if something
is wrong and prepare the data to be in good shape for the algorithms.

After the data is processed, the results will be sent in a message to kafka. The
messages have a JSON header with general information (like the partition,
application name, name of the algorithm, etc) and then an encoded message with
the data. The encoding is done using [msgpack](https://msgpack.org/) which is
the same library that is used for encoding DAQ messages. The data is decoded in
the [dqm-backend](https://github.com/DUNE-DAQ/dqm-backend). When the messages
are bigger than what kafka can take in a single message (which can be passed as
a parameter to DQM), the messages are split in pieces and reconstructed in the
backend.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jmcarcell_

_Date: Mon Oct 3 19:28:14 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dqm/issues](https://github.com/DUNE-DAQ/dqm/issues)_
</font>
