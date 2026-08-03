# Survey of trigger and readout window configurations that are used in existing integtests, Summer 2026

## Introduction

Here a list of the trigger sources that we typically use in integration/regression tests (and emulated-data running generally):


* **RandomTriggerCandidateMaker**

    * This software module typically runs in the MLTApplication (along with the _MLTModule_ and the _DataHandlerModule_ that converts TriggerActivity objects into TriggerCandidate objects), and it receives TimeSync messages from the ReadoutApplications so that it knows what DTS (DUNE Timing System) timestamps are currently being processed by the emulated-data system.  It has the ability to produce periodic triggers at a configurable rate, and it uses the knowledge of "detector time" that it gains from the TimeSync messages to provide a useful timestamp in the TriggerCandidate objects that it creates.

    * Trigger records that are produced from these triggers have a TriggerCandidate type of _kRandom_ assigned to them.

* **FakeHSIEventGenerator**

    * This software module typically runs in the FakeHSIApplication (along with the _HSIDataHandlerModule_), and it receives TimeSync messages from the ReadoutApplications so that it knows what DTS (DUNE Timing System) timestamps are currently being processed by the emulated-data system.  It has the ability to produce periodic triggers at a configurable rate, and it uses the knowledge of "detector time" that it gains from the TimeSync messages to provide a useful timestamp in the TriggerCandidate objects that it creates.

    * Trigger records that are produced from these triggers have a TriggerCandidate type of _kTiming_ assigned to them.

* **TriggerActivity and TriggerCandidate objects derived from TriggerPrimitives**

    * The software modules that produce TAs and TCs run in the ReadoutApps, TriggerApps, and the MLT.

    * In our integration tests, we have examples of creating TPs from WIB data and from DAPHNE data.

        * For WIB data, we typically use a data-replay file that has all of the ADC values set to zero.  We combine this with software (`SourceEmulatorModel`) that modifies every Nth ADC value to a large number, where N is configurable.  In this way, we can set the rate of TPs to match the needs of the integration test.

        * For DAPHNE data, we use a data-replay file taken from a particular run at EHN1.  That file has some number of TPs in the data, and we tune parameters of the DAQ system to provide the desired TA and TC rates for a given integration test.

    * In both cases, we configure the TA and TC makers to simply produce one output trigger object for every N input objects ("prescaling" the input messages).  The baseline values for the TP->TA and TA->TC prescales are 1000 and 100, respectively.

    * Trigger records that are produced from these triggers have a TriggerCandidate type of _kPrescale_ assigned to them.

    * To calculate the expected rate of TP-based triggers from emulated WIB data, we multiply the number of emulated WIBs in the system by 64 (the number of channels per WIB), and multiply that value by 100 and the SourceEmu TP_rate parameter.  The SourceEmulator code is designed to produce 100 Hz of TPs times its configured "rate" value.

    * So, for 6 WIBs and a configured SourceEmu TP_rate of 1, the rate of TPs would be (6 * 64 * 100 * 1) = 38400.

    * Dividing this number by TA and TC prescale values of 100 gives the expected rate of triggers, e.g. 38400 / 100 / 100 = 3.8 Hz.

The readout windows that are assigned to each trigger can be configured in the MLT or in modules that are upstream of that.

## Configured trigger types, trigger rates, readout window widths, etc.

The tables in this section list the configuration parameters that are set for each of the integration tests.  If an integtest uses more than one DUNE-DAQ configuration, the super-set of trigger types is listed.  If a given test does not use a particular trigger type, nothing is listed.

To help save space in the table cells, the following abbreviations are used:


* RWBT - readout window begin ticks - this value determines the beginning of the readout window.  It is added to the trigger time to determine the beginning of the readout window.  Obviously, if this value is less than zero, the result is a timestamp that is earlier than the trigger time.

* RWET - readout window end ticks - this value determines the end of the readout window.  It is added to the trigger time to determine the end of the readout window.

* RWW - readout window width, in either DTS clock ticks, wallclock time, or both.

### Integtests in the _daqsystemtest_ repo:

| Integtest name | RTCM | FakeHSI | Triggers from TPs |
| --- | :---: | :---: | :---: |
| 3ru_1df_multirun_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | number of WIBs=9, SourceEmu TP_rate param=1, TAMakerPrescale=100, TCMakerPrescale=100, calculated 5.8 Hz, observed 5.5 Hz, RWBT=0, RWET=32, RWW=512 nsec |
| 3ru_3df_multirun_test.py | 3 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | number of WIBs=6, SourceEmu TP_rate param=1, TAMakerPrescale=100, TCMakerPrescale=100, calculated 3.8 Hz, observed 3.6 Hz, RWBT=0, RWET=32, RWW=512 nsec |
| disabled_tpg_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | 3 Hz trigger rate, RWBT=-3000, RWET=1001, RWW=64.02 usec | - |
| example_system_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | 3 Hz trigger rate, RWBT=-3000, RWET=1001, RWW=64.02 usec | number of WIBs=4 or 8, SourceEmu TP_rate param=1, TAMakerPrescale=1000, TCMakerPrescale=100, observed 0.25 or 0.5 Hz, RWBT=0, RWET=32, RWW=512 nsec |
| fake_data_producer_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=2001, RWW=64.02 usec | - | - |
| long_window_readout_test.py | 0.05 Hz trigger rate, RWBT=-100000000, RWET=1000000, RWW=1.62 sec | - | - |
| minimal_system_quick_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | - |
| readout_type_scan_test.py | 1 Hz trigger rate, various readout window widths | - | various rates and readout window widths |
| sample_ehn1_multihost_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | 3 Hz trigger rate, RWBT=-3000, RWET=1001, RWW=64.02 usec | number of WIBs=4, SourceEmu TP_rate param=1, TAMakerPrescale=1000, TCMakerPrescale=100, observed 0.25 Hz, RWBT=0, RWET=32, RWW=512 nsec |
| small_footprint_quick_test.py | - | 1 Hz trigger rate, RWBT=-3000, RWET=1001, RWW=64.02 usec  | - |
| tpg_state_collection_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | - |
| tpreplay_test.py | 0 Hz | - | - |
| tpstream_writing_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | number of WIBs=2, SourceEmu TP_rate param=1, TAMakerPrescale=25, TCMakerPrescale=100, calculated 5.1 Hz, observed 4.9 Hz, RWBT=0, RWET=32, RWW=512 nsec |
| trigger_bitwords_test.py | typical rate and readout window plus 40 Hz trigger rate, RWBT=-62500, RWET=62500 | typical rates and readout window plus 30 Hz trigger rate, RWBT=-62500, RWET=62500 | - |

### Integtests in the _dfmodules_ repo:

| Integtest name | RTCM | FakeHSI | Triggers from TPs |
| --- | :---: | :---: | :---: |
| disabled_output_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | number of WIBs=2, SourceEmu TP_rate param=1, TAMakerPrescale=25, TCMakerPrescale=100, calculated 5.1 Hz, observed 4.9 Hz, RWBT=0, RWET=32, RWW=512 nsec  |
| hdf5_compression_test.py| - | 10 Hz trigger rate, RWBT=-120000, RWET=1000, RWW=1.94 msec | number of emulated DAPHNE cards=6, DAPHNE replay data from run 36012, TAMakerPrescale=2000, TCMakerPrescale=100, observed ~2.1 Hz, RWBT=0, RWET=3040, RWW=48.6 usec |
| insufficient_disk_space_test.py | 0.2 Hz trigger rate, RWBT=-9000000, RWET=1000000, RWW=160 msec | - | - |
| large_trigger_record_test.py | 0.06 Hz trigger rate, RWBT=-10000000 or -25000000, RWET=1000000, RWW=176 or 416 msec | - | - |
| max_file_size_test.py | - | 10 Hz trigger rate, RWBT=-52000, RWET=1000, RWW=848 usec | number of WIBs=6, SourceEmu TP_rate param=5, TAMakerPrescale=1000, TCMakerPrescale=100, calculated 1.92 Hz, observed 1.84 Hz, RWBT=0, RWET=32, RWW=512 nsec |
| multiple_data_writers_test.py | - | 10 Hz trigger rate, RWBT=-52000, RWET=1000, RWW=848 usec | - |
| offline_prod_run_test.py | - | 1 Hz trigger rate, RWBT=-3000, RWET=1001, RWW=64.02 usec | - |
| trmonrequestor_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | - | - |

### Other integtests:

| Integtest name | RTCM | FakeHSI | Triggers from TPs |
| --- | :---: | :---: | :---: |
| crtmodules/crt_frame_builder_test.py | 1 Hz trigger rate, RWBT=-2000, RWET=5, RWW=32.1 usec | 3 Hz trigger rate, RWBT=-3000, RWET=1001, RWW=64.02 usec | - |
| hsilibs/iceberg_real_hsi_test.py | this test needs to be updated for v5 configurations | | |
| listrev/listrev_test.py | this test does not use DUNE DAQ triggers | | |
| snbmodules/simple_transform_test.py | - | - | this test appears to use an SNB trigger (kSupernova) with RWBT=0, RWET=200704, RWW=3.2 msec |
| trigger/change_rate_test.py | 2, 1, 0.1, and 0.01 Hz trigger rates, RWBT=-1000, RWET=1001, RWW=32 usec | - | - |


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Thu Jul 2 13:57:27 2026 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/integrationtest/issues](https://github.com/DUNE-DAQ/integrationtest/issues)_
</font>
