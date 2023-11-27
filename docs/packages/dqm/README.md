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

        fddaqconf_gen -c config.json --hardware-map-file HardwareMap.txt --enable-dqm conf_with_dqm

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

    ```
    "raw_params": ["time", "num_frames"]
    ```
  Where `time` is the time in seconds between runs of the algorithm and
  `num_frames` is the number of frames used (only for DQM-RU apps). So if we
  want to get updates for the raw data stream every minute and get 100 frames
  then we would have
    ```
    "raw_params": ["60", "100"]
    ```

* STD: Standard deviation of the ADC distribution over a window of time. To modify use:
    ```
    "std_params": ["time", "num_frames"]
    ```

* RMS: RMS of the ADC distribution over a window of time, not to be confused
  with the standard deviation. To modify use:
    ```
    "rms_params": ["time", "num_frames"]
    ```


* Fourier transform: The fourier transform of ADC time series. Can be done for
  each channel or for each plane (by summing all the ADC time series and doing
  the fourier transform of the result). To modify use for each channel or for
  each plane respectively:
    ```
    "fourier_channel_params": ["time", "num_frames"],
    "fourier_plane_params": ["time", "num_frames"]
    ```

## Channel map
DQM always runs with a channel map. At the beginning of the run it takes data to
check which offline channels and planes it will have to map to and saves those
for later.

There is a set of valid channel map names for DQM (when generation the
configuration for `nanorc`).
The mapping between those values and the name that
they receive in `detchannelmaps` is the following:
```
{"HD", "ProtoDUNESP1ChannelMap"},
{"VD", "VDColdboxChannelMap"},
{"PD2HD", "PD2HDChannelMap"},
{"HDCB", "HDColdboxChannelMap"}
```

which means that the valid names in DQM are `HD`, `VD`, `PD2HD`, `HDCB`.

## How to add an algorithm to DQM

Algorithms in DQM are currently structured in two different parts: one is what
the algorithm does for a single unit (for example, a single channel or a single
plane) that is going to be processed. The other part describes how to run on the
data and the message that is going to be transmitted. An algorithm can be then
implemented in a custom way or helpers can be used, depending on how the
algorithm runs. It has to inherit from the `AnalysisModule` class, which will
guarantee that it has some methods such as `run` that are then called.

- Algorithm that does something for every channel:

    In this case there is a helper class [ChannelStream](../src/ChannelStream.hpp)
that can be used to simplify the implementation. After implementing the
algorithm itself, we provide the function that will run on every channel and the
`ChannelStream` class will be in charge of running it for every channel and then
sending the messages to kafka. An example of this is the implementation of the
standard deviation, where the actual algorithm is implemented in the class
`STD`:

    ```
    class STDModule : public ChannelStream<STD, double>    // Class of the algorithm and type of the result
    {
    public:
      STDModule(std::string name,
                int nchannels,
                std::vector<int>& link_idx);
    };
    STDModule::STDModule(std::string name,
                                 int nchannels,
                                 std::vector<int>& link_idx
                         )
      : ChannelStream(name, nchannels, link_idx,
                      [this] (std::vector<STD>& vec, int ch, int link) -> std::vector<double> {
                        return {vec[get_local_index(ch, link)].std()};})
    {
    }
    ```

    where at the end we pass a lambda function with the function that is going to
run for each channel. The `ChannelStream` class will format and send the
messages to kafka in a way that is easy to parse.

After the implementation of the algorithm has been added in DQM there are a few
other places where something has to be added:
- Configurations parameter to the schema (and also in `daqconf`)
- Add the algorithm in the `DQMProcessor` class so it can be run
- For the DQM-DF apps it also has to be added to the `DFModule` class

After the algorithm has been added, proper parsing has to be done in
[dqm-backend](https://github.com/DUNE-DAQ/dqm-backend) to display or further
process the data.

### How to add algorithms in python to DQM (experimental)
For this to work, the python component of the boost library needs to be
installed (not shipped with the dunedaq externals at the time of writing,
13/11/2022). This component is very easy to install, once installed run

```
export BOOST_PYTHON=/path/to/boost/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BOOST_PYTHON
```

then enable the option to compile with python support in the CMakeLists.txt. To
be able to send messages to kafka the packages `kafka-python` and `msgpack` need
to be installed and to run FFTs in python `scipy` has to be installed. After
generating a configuration for nanorc, the file `boot.json` has to be changed to
add `PYTHONPATH` to the list of variables that `nanorc` will get, and this is
how we add it so that it is picked from the environment:
```
                "PATH": "getenv",
                "TIMING_SHARE": "getenv",
                "TRACE_FILE": "getenv:/tmp/trace_buffer_{APP_HOST}_{DUNEDAQ_PARTITION}",
                "PYTHONPATH": "getenv"
```


## How to add a frontend type to DQM

Each algorithm is templated and it has to know what to do for each format, which
means the frontend has to be added to each algorithm individidually or to the
`ChannelStream` class if it's being used, which could mean modifying how it runs
and or the messages that are being transmitted. This also includes
[ChannelMapFiller.hpp](../src/ChannelMapFiller.hpp), since it is being run as
another algorithm. Note that algorithms use helper templated functions to get
the ADCs or timestamps or other numbers that can be found in
[FormatUtils.hpp](../include/dqm/FormatUtils.hpp).

If the decoding is different then a specialization of the template should be
made for the `Decoder` class.

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
`fddetdataformats::WIBFrame`). Pointers to the data are extracted from the
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

## Testing

### Unit tests
Unit tests can be run with
```
dbt-build.sh --unittest
```

There are a few unit tests for the algorithms, ideally each algorithm should
have a set of unit tests to make sure they are working correctly (which doesn't
mean they will work correctly since the final setup is more complicated).

### Creating files
Another way of testing DQM is to create files with specific patterns to check
the plots and see what we expect. There is a script called `filegen.py` that can be used for that. 
By running
```
python sourcecode/dqm/scripts/filegen.py --frontend wib2 --pattern sin --num-frames 100
```
we'll create a binary file with `WIB2Frame`s and for each channel the waveform
is a sine with a given frequency. Then, the FFT plots can be checked to make
sure that there is a peak at the frequency that was set for the sine. There is
another pattern to check that the standard deviation is calculated correctly.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Wesley Ketchum_

_Date: Thu Sep 28 14:47:18 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dqm/issues](https://github.com/DUNE-DAQ/dqm/issues)_
</font>
