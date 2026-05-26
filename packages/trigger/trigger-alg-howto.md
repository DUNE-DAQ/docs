# How to write a trigger algorithm

The DUNE DAQ data selection software separates physics algorithms
(which make trigger activity and trigger candidate objects) from
concerns about how the data objects are packaged and transported
through the data selection system.

Physics algorithms are implemented in the [`triggeralgs`](https://github.com/DUNE-DAQ/triggeralgs) package. To create a new physics algorithm, create a class that derives from [`triggeralgs::TriggerActivityMaker`](https://github.com/DUNE-DAQ/triggeralgs/blob/develop/include/triggeralgs/TriggerActivityMaker.hpp) or [`triggeralgs::TriggerCandidateMaker`](https://github.com/DUNE-DAQ/triggeralgs/blob/develop/include/triggeralgs/TriggerCandidateMaker.hpp) as appropriate. I'll use `TriggerActivityMaker` for definiteness from here on: if you're writing a `TriggerCandidateMaker`, make the appropriate substitutions.

In your derived class, you must implement one pure virtual function, namely:

```cpp
void process(const TriggerPrimitive& input_tp, std::vector<TriggerActivity>& output_ta);
```

This function will be called by the data selection framework once for each input `TriggerPrimitive`. Your implementation should do whatever processing it wants, and if the addition of the latest `TriggerPrimitive` causes a new output `TriggerActivity` to be complete, add the `TriggerActivity` to the output vector `output_ta`.

The data selection framework will make calls to `operator()` (with the `TriggerPrimitive`s strictly ordered by start time), which in turn calls the user-defined `process()` function. That is, once `operator()` has been called with a `TriggerPrimitive` whose start time is `T`, it will not later be called with a `TriggerPrimitive` whose start time is less than `T`. (If two `TriggerPrimitives` have exactly the same time, the relative order of the calls to `operator()` is by channel number.)

You will of course need to store the state of your algorithm between calls to `process()`: use member variables in your class for this.

It's recommended (but not strictly required) to also implement the `flush()` function from `TriggerActivityMaker`, whose signature is:

<!---
COMMENTED OUT - FLUSH NOT CURRENTLY USED IN THE TRIGGER
```cpp
virtual void flush(timestamp_t until, std::vector<TriggerActivity>& output_ta)
```

The reason this function exists is to handle the case where there is a large gap between trigger primitives (or, more likely, between trigger activities). During this gap, `operator()` is not called, and so your algorithm cannot send its output, even if such a long time has passed that you know that any trigger activities currently in progress can be completed and sent out. In this case, the data selection framework calls your implementation of `flush(until, output_ta)` to inform you that no more trigger primitives have occurred between the last one for which `operator()` was called and timestamp `until`. If this causes your algorithm to complete any trigger activities, you can add them to the `output_ta` vector.
--->

Finally, you must register the `TriggerActivityMaker` in the Trigger Activity Factory. This allows it to be accessed in this repository and used when running on `drunc`. In the case of `TAMakerPrescaleAlgorithm`, the macro call is:

```cpp
REGISTER_TRIGGER_ACTIVITY_MAKER(TRACE_NAME, TAMakerPrescaleAlgorithm)
```

where `TRACE_NAME` is the string `"TAMakerPrescaleAlgorithm"`, and should be defined as such at the top of the source file, e.g.

```cpp
#include "triggeralgs/Prescale/TAMakerPrescaleAlgorithm.hpp"
#include "TRACE/trace.h"
#define TRACE_NAME "TAMakerPrescaleAlgorithm"
```

## Configuration

Your algorithm has to take configuration parameters at run time (e.g., a minimum number of hits or ADC to form a trigger activity, or a verbosity level). This means you have to write an xml configuration schema for your algorithm in the `appmodel` repository. Here is an example for `ADCSimpleWindow` algorithm, defined in [`appmodel/schema/appmodel/trigger.schema.xml`](https://github.com/DUNE-DAQ/appmodel/blob/develop/schema/appmodel/trigger.schema.xml).

```xml
 <class name="TAMakerADCSimpleWindowAlgorithm">
  <superclass name="TAAlgorithm"/>
  <attribute name="adc_threshold" description="Threshold for the ADC integral algorithm" type="u32" init-value="10000" is-not-null="yes"/>
  <attribute name="window_length" description="Window length (in ticks) for the ADC integral algorithm" type="u32" init-value="10000" is-not-null="yes"/>
 </class>
```

The schema defines the configuration object, that can then be created. Please see these module configurations: [`moduleconfs`](https://github.com/DUNE-DAQ/daqsystemtest/blob/develop/config/daqsystemtest/moduleconfs.data.xml), where the configuration objects are created and linked to the trigger application.

Your algorithm receives a configuration object with its parameters via the `configure()` function that has to be overriden, with signature:

```cpp
void configure(const nlohmann::json &config);
```

The `config` argument is in `nlohmann::json` format, documentation for which can be found at https://json.nlohmann.me/ . Here is a simple example implementation, from the `TAMakerADCSimpleWindowAlgorithm` algorithm:

```cpp
void
TAMakerADCSimpleWindowAlgorithm::configure(const nlohmann::json &config)
{
  TriggerActivityMaker::configure(config);

  if (config.is_object()) {
    if (config.contains("window_length")) {
      m_window_length = config["window_length"];
    }
    if (config.contains("adc_threshold")) {
      m_adc_threshold = config["adc_threshold"];
    }
  }
}
```

The `TriggerActivityMaker::configure(config);` is needed to call the base-class default configuration, that controlls e.g. prescaling.

## Aggregation

Inputs from a number of sources may be aggregated to send to a physics algorithm. The standard aggregation is that a `TriggerActivityMaker` receives trigger primitives aggregated over one plane of APA/CRP, and a `TriggerCandidateMaker` receives trigger activities aggregated over the whole detector, all planes. We can consider alterations and additions to this scheme in future.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: ArturSztuc_

_Date: Mon Nov 18 09:11:35 2024 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/trigger/issues](https://github.com/DUNE-DAQ/trigger/issues)_
</font>
