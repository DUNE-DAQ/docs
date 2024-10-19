# SmartDaqApplication

The SmartDaqApplication class allows for automatic creation of modules and connections for a known application. The general pattern is that a SDA ingests a set of module configuration objects and connection rules and uses them to create a well-defined application with modules, internal connections, and external connections.

## Writing a new SmartDaqApplication

SmartDaqApplications implement the `std::vector<const confmodel::DaqModule*> generate_modules(conffwk::Configuration*, const std::string&, const comnfmodel::Session*)` method, which is responsible for generating a set of modules and connection objects. Each SmartDaqApplication has a UID from the configuration.

This section will use the "[DFOApplication](https://github.com/DUNE-DAQ/appmodel/blob/develop/src/DFOApplication.cpp)" SmartDaqApplication as an example.

### Boilerplate

The following code must be in your source file to allow the system to instantiate your SmartDaqApplication correctly. The first parameter should be changed to match your SmartDaqApplication class name.
```C++
static ModuleFactory::Registrator __reg__("DFOApplication",
                                          [](const SmartDaqApplication* smartApp,
                                             conffwk::Configuration* confdb,
                                             const std::string& dbfile,
                                             const confmodel::Session* session) -> ModuleFactory::ReturnType {
                                            auto app = smartApp->cast<DFOApplication>();
                                            return app->generate_modules(confdb, dbfile, session);
                                          });

```

### Creating a module

```C++
  std::string dfoUid("DFO-" + UID());
  conffwk::ConfigObject dfoObj;
  TLOG_DEBUG(7) << "creating OKS configuration object for DFOModule class ";
  confdb->create(dbfile, "DFOModule", dfoUid, dfoObj);

  auto dfoConf = get_dfo();
  dfoObj.set_obj("configuration", &dfoConf->config_object());
```

Here, it is important to understand the DFOApplication schema definition:
```XML
 <class name="DFOApplication">
  <superclass name="SmartDaqApplication"/>
  <relationship name="dfo" class-type="DFOConf" low-cc="one" high-cc="one" is-composite="no" is-exclusive="no" is-dependent="no"/>
  <method name="generate_modules" description="Generate DaqModule dal objects for streams of the application on the fly">
   <method-implementation language="c++" prototype="std::vector&lt;const dunedaq::confmodel::DaqModule*&gt; generate_modules(conffwk::Configuration*, const std::string&amp;, const confmodel::Session*) const override" body=""/>
  </method>
 </class>
```
In addition to the fields from SmartDaqApplication, the DFOApplication class has a relationship named "dfo" to a `DFOConf` object. As an OKS object, it also has a "UID"" field. The code uses this UID (accessed via the `UID()` method) to create the UID for a `DFOModule` object. The object is created in the in-memory database, and its configuration assigned using the "dfo" relationship from the DFOApplication schema.

### Reading connection rules and creating connections

```C++

  for (auto rule : get_network_rules()) {
    auto endpoint_class = rule->get_endpoint_class();
    auto descriptor = rule->get_descriptor();

    conffwk::ConfigObject connObj;
    auto serviceObj = descriptor->get_associated_service()->config_object();
    std::string connUid(descriptor->get_uid_base());
    confdb->create(dbfile, "NetworkConnection", connUid, connObj);
    connObj.set_by_val<std::string>("data_type", descriptor->get_data_type());
    connObj.set_by_val<std::string>("connection_type", descriptor->get_connection_type());
    connObj.set_obj("associated_service", &serviceObj);

    //if (endpoint_class == "DFOModule") {
    if (descriptor->get_data_type() == "TriggerDecision") {
        tdInObj = connObj;
        input_conns.push_back(&tdInObj);
      } 
    else if (descriptor->get_data_type() == "TriggerDecisionToken") {
        tokenInObj = connObj;
        input_conns.push_back(&tokenInObj);
      }
    
    else if (descriptor->get_data_type() == "TriggerInhibit") {
	busyOutObj = connObj;
        output_conns.push_back(&busyOutObj);
    }
  }

```

The next stage of DFOApplication is to retrieve the network connection rules to assign the inputs and outputs of the `DFOModule` instance. A DFO has two fixed inputs (decisions and tokens), and one fixed output (inhibits). Decisions sent to TRB instances are dynamically instantiated at run-time using information in the token messages.

### Setting Module Connection relationships

```C++
  dfoObj.set_objs("inputs", input_conns);
  dfoObj.set_objs("outputs", output_conns);

  // Add to our list of modules to return
  modules.push_back(confdb->get<DFOModule>(dfoUid));

  return modules;
```

Once the fixed connections are retrieved using the network rules, the module's input and output relations are set, and the module is added to the output vector, which is returned.

### Summary

These basic steps are repeated in all SmartDaqApplication instances, with differences depending on the specific applciation being implemented. The DFOApplication is one of the simplest applications in the system, but it demonstrates the basic logic followed by all SmartDaqApplications.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Jul 10 08:53:27 2024 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/appmodel/issues](https://github.com/DUNE-DAQ/appmodel/issues)_
</font>
