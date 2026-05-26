# Introduction

With the connectivity service changes, it is now possible for DAQ modules to generate their own connection names, as long as both ends of the connection agree on the naming convention in use. This document shows an example of using these dynamic connection names for the TriggerRecordBuilder.

# Configuration-based
```cpp
void
TriggerRecordBuilder::init(const data_t& init_data)
{

  TLOG_DEBUG(TLVL_ENTER_EXIT_METHODS) << get_name() << ": Entering init() method";

  //--------------------------------
  // Get single queues
  //---------------------------------

  auto ci = appfwk::connection_index(init_data, { "trigger_decision_input", "trigger_record_output" });

  auto iom = iomanager::IOManager::get();
  m_trigger_decision_input = iom->get_receiver<dfmessages::TriggerDecision>(ci["trigger_decision_input"]);
  m_trigger_record_output =
    iom->get_sender<std::unique_ptr<daqdataformats::TriggerRecord>>(ci["trigger_record_output"]);

  //----------------------
  // Get dynamic queues
  //----------------------

  // set names for the fragment connections
  auto ini = init_data.get<appfwk::app::ModInit>();

  // get the names for the fragment connections
  // there is an optional connection, which is the connection to DQM
  // Since it's optional, we need to loop over all the connections
  // to check if it's there and act accordingly

  for (const auto& ref : ini.conn_refs) {
    if (ref.name.rfind("data_fragment_") == 0) {
      m_fragment_inputs.push_back(iom->get_receiver<std::unique_ptr<daqdataformats::Fragment>>(ref.uid));
    } else if (ref.name == "mon_connection") {
      m_mon_receiver = iom->get_receiver<dfmessages::TRMonRequest>(ref.uid);
    }
  }

  TLOG_DEBUG(TLVL_ENTER_EXIT_METHODS) << get_name() << ": Exiting init() method";
}
```

# Using dynamic names
```cpp
void
TriggerRecordBuilder::init(const data_t& init_data)
{

  TLOG_DEBUG(TLVL_ENTER_EXIT_METHODS) << get_name() << ": Entering init() method";

  m_trigger_decision_input = get_iom_receiver<dfmessages::TriggerDecision>("trigger_decisions_for_" + m_this_trb_source_id.to_string());
    m_trigger_record_output = get_iom_sender<std::unique_ptr<daqdataformats::TriggerRecord>>(appfwk::connection_inst(init_data, "trigger_record_output"));
    
    // Only one Fragment input now, maybe change this to a single Receiver?
    m_fragment_inputs.push_back(get_iom_receiver<std::unique_ptr<daqdataformats::Fragment>>("fragments_for_" + m_this_trb_source_id.to_string())); // This will also be put into DataRequests, no need for readout to worry about it
    
    m_mon_receiver = get_iom_receiver<dfmessages:TRMonRequest>("trmon_requests_for_" + m_this_trb_source_id.to_string()); // No harm in always listening
    
  TLOG_DEBUG(TLVL_ENTER_EXIT_METHODS) << get_name() << ": Exiting init() method";
}
```

# Notes

Types of Sender/Receiver instances are not changed, so `m_trigger_decision_input` is still an `iomanager::Receiver<dfmessages::TriggerDecision>`, and will only receive TriggerDecision objects.

The "Current" style of retrieving connection information from configuration is still perfectly valid, and should be used where appropriate. (For example, the trigger_record_output connection above.)

Names such as "trigger_decsisions_for_" are for human readability, and are not required, as long as the generated portion (e.g. m_this_trb_source_id.to_string()) will be unique *for that data type*.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Thu Jan 19 08:49:53 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/iomanager/issues](https://github.com/DUNE-DAQ/iomanager/issues)_
</font>
