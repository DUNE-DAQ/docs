
# An Introduction to OKS

## Overview

OKS (Object Kernel Support) is a suite of packages [originally
written](https://gitlab.cern.ch/atlas-tdaq-software/oks) for the ATLAS
data acquisition effort. Its features include:

* The ability to define object types in XML (known as OKS "classes"), off of which C++ and Python classes can automatically be generated

* Support for class Attributes, Relationships, and Methods. Attributes and Relationships are automatically generated; Methods allow developers to add behavior to classes

* The ability to create instances of classes (known as OKS "objects"), modify them, read them into an XML file serving as a database and retrieve them from the database

This document provides a taste of what OKS has to offer.

## Getting Started

To get started working with the DUNE-repurposed OKS packages, you'll want to [set up a work area](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/) based off of a nightly from June 9, 2023 or later; these nightlies will contain the suite of OKS packages as well as a version of daq-cmake (`v2.3.1`) capable of handling the code generation facilities of OKS. You can also develop and build the OKS packages in a work area based on this release; these packages include [dbe (the DataBase Editor GUI)](https://github.com/DUNE-DAQ/dbe#readme), dal (Data Access Library, this repo), [oksutils](https://github.com/DUNE-DAQ/oksutils), [genconfig](https://github.com/DUNE-DAQ/genconfig) (contains code generation executable), [oks](https://github.com/DUNE-DAQ/oks) (core OKS functionality, not to be confused with the entire OKS suite), [oksdbinterfaces](https://github.com/DUNE-DAQ/oksdbinterfaces), [oksconfig](https://github.com/DUNE-DAQ/oksconfig) and [okssystem](https://github.com/DUNE-DAQ/okssystem). Some of these packages you may never need to worry about, others (such as the dbe GUI) may benefit from further development. 
  
With the work area set up, it's time to run some tests to make sure things are in working order. These include:

* `test_configuration.py`: A test script in the oksdbinterfaces package. Tests that you can create objects, save them to a database, read them back, and remove them from a database.

* `test_dal.py`: Also from the oksdbinterfaces package. Test that you can change the values of objects, and get expected errors if you assign out-of-range values. 

* `algorithm_tests.py`: A script from the dal package. Test that Python bindings to class Methods implemented in C++ work as expected. 

If anything goes wrong during the tests, it will be self-evident. 

## A Look at OKS Databases: XML-Represented Classes and Objects

While ATLAS has various database implementations (Oracle-based, etc.), for the DUNE DAQ we only need their basic database format, which is an XML file on disk. There are generally two types of database file: the kind that defines classes, which by convention have the `*.class.xml` extension, and the kind that define instances of those classes (i.e. objects) and have `*.data.xml` extensions. The class files are known from ATLAS as "schema files" and the object files are known from ATLAS as "data files". A good way to get a feel for these files is to start with the tutorial schema, `$DAL_SHARE/schema/dal/tutorial.schema.xml`. Copy it over into your work area. 

### Overview of `tutorial.schema.xml`

Let's start with a description of what `tutorial.schema.xml` contains before we even look at its contents. It describes via three classes needed for a (very) simple DAQ: `ReadoutApplication` for detector readout, `RCApplication` for the Run Control in charge of `ReadoutApplication` instances, and a third class, `Application`, of which they're both subclasses. Open the file, and *unless you're purely curious, scroll past the lengthy header which you'll never need to understand* until you see the following:
```
 <class name="Application" description="A software executable" is-abstract="yes">
  <attribute name="Name" description="Name of the executable, including full path" type="string" init-value="Unknown" is-not-null="yes"/>
 </class>
```
(_n.b. if you want to use `emacs` in this environment you may need to run `spack unload cairo`; this hasn't apparently had any negative effects on OKS functionality_). The `is-abstract` qualifier means that you can't have an object which is concretely of type `Application`, you can only have objects of subclasses of `Application`. However, any class which is a subclass of `Application` will automatically contain a `Name` attribute, which here is intended to be the fully-qualified path of the executable in a running DAQ system. 

Next, we see the class for readout:
```
<class name="ReadoutApplication" description="An executable which reads out subdetectors">
  <superclass name="Application"/>
  <attribute name="SubDetector" description="An enum to describe what type of subdetector it can read out" type="enum" range="PMT,WireChamber" init-value="WireChamber"/>
 </class>
```
...where you can see that there's an OKS enumerated type, where here there are only two options, basically a photon detector or a TPC. 

Then, there's the run control application:
```
<class name="RCApplication" description="An executable which allows users to control datataking">
  <superclass name="Application"/>
  <attribute name="Timeout" description="Seconds to wait before giving up on a transition" type="u16" range="1..3600" init-value="20" is-not-null="yes"/>
  <relationship name="ApplicationsControlled" description="Applications RC is in charge of" class-type="Application" low-cc="one" high-cc="many"/>
 </class>
```
And here, we have two items of interest: 

* A `Timeout` Attribute representing the max number of seconds before giving up on a transition. Represented by an unsigned 2-byte integer, the max timeout is one hour, and defaults to 20 seconds. 

* An `ApplicationsControlled` Relationship, which refers to anywhere from one object subclassed from `Application` to "many", which is OKS-speak for "basically unlimited". 

OKS also provides tools which parse the XML and provide summaries of the contents of the database (XML file). `config_dump`, part of the oksdbinterfaces package, is quite useful in this regard. Pass it `-h` to get a description of its abilities; if you just run `config_dump -d oksconfig:tutorial.schema.xml` you'll get a summary of the classes used to defined the objects in the file. Running `config_dump -d oksconfig:tutorial.schema.xml -C` will give you much more detail. For a schema as simple as the one we're showing here, this tool isn't super-useful, but it can be powerful when schemas get bigger and more complex. 

### Overview of `tutorial.data.xml`

In this section, we're going to _make_ a data file using the classes from `tutorial.schema.xml`. It's extremely simple, just run this script:
```
tutorial.py 
```
...and it will produce `tutorial.data.xml`. We'll look at it in a moment, but two things to note first:


1. As you can see if you open up `tutorial.py`, a Python module is actually _generated_ off of `tutorial.schema.xml`. If we add Attributes, Relations, etc. to the classes, the Python code will automatically pick them up without any additional Python needing to be written. 


1. `config_dump -d oksconfig:tutorial.data.xml --list-objects --print-referenced-by` provides a nice summary of `tutorial.data.xml`'s contents

We can also see what `tutorial.py` created by opening up `tutorial.data.xml`. Again, please scroll past the extensive header. What we see is two types of readout application, one ID'd as `PhotonReadout` and the other ID'd as `TPCReadout`; these names, of course, are chosen to reflect the choice of the `SubDetector` enum. Then we also see an instance of `RCApplication` where the `ApplicationsControlled` relationship establishes that run control is in charge of the two readout applications:
```
<obj class="RCApplication" id="DummyRC">
 <attr name="Name" type="string" val="/full/pathname/of/RC/executable"/>
 <attr name="Timeout" type="u16" val="20"/>
 <rel name="ApplicationsControlled">
  <ref class="ReadoutApplication" id="PhotonReadout"/>
  <ref class="ReadoutApplication" id="TPCReadout"/>
 </rel>
</obj>
```
The run control timeout is set to its default of 20 seconds. Say we want to change this, and save the result. For such a small data file it would be easy to manually edit, but if you think of a full-blown DAQ system you'll want to automate a lot of things. Fortunately we can alter the value via Python. Go into an interactive Python environment and do the following:
```
import oksdbinterfaces
db = oksdbinterfaces.Configuration('oksconfig:tutorial.data.xml')
rc = db.get_dal("RCApplication", "DummyRC")  # i.e., first argument is name of the class, the second is the name of the object
print(rc.Timeout)
```
where in the last command, you see the timeout of 20 seconds.

For fun, let's try to set the timeout to an illegal value (i.e., a timeout greater than an hour):
```
rc.Timeout = 7200 # 2 hrs before run control gives up!
```
...you'll get a `ValueError`. 

Let's set it to a less-ridiculous 60 seconds, and save the result:
```
rc.Timeout = 60
db.update_dal(rc)
db.commit()
```
If we exit out of Python and look at `tutorial.data.xml`, we see the timeout is now 60 rather than 20. And if we read the data file back in, this update will be reflected. 

You're encouraged to experiment yourself with the objects, either interactively or via checking out the dal repo and editing `sourcecode/dal/scripts/tutorial.py`; make sure to run `dbt-build` in the case of the latter. 


## A Realistic Example

The `tutorial.schema.xml` file and `tutorial.data.xml` files are fairly easy to understand, and meant to be for educational purposes. To see the actual classes which are used on ATLAS, we can look at the following: `$DAL_SHARE/schema/dal/core.schema.xml`. This file is quite large, and describes classes which actually model ATLAS's DAQ systems like `ComputerProgram` and `Rack` and `Crate`. If you look in [dal's `CMakeLists.txt` file](https://github.com/DUNE-DAQ/dal/blob/develop/CMakeLists.txt) you see the following:
```
daq_oks_codegen(core.schema.xml)
  
daq_add_library(algorithms.cpp disabled-components.cpp test_circular_dependency.cpp LINK_LIBRARIES oksdbinterfaces::oksdbinterfaces okssystem::okssystem logging::logging dal_oks)
```
`core.schema.xml` gets fed into `daq_oks_codegen` which proceeds to (1) generate code off of the classes defined in `core.schema.xml` and (2) produce a shared object library which you can subsequently refer to as `dal_oks`. Details on `daq_oks_codegen` can be found [here](https://github.com/DUNE-DAQ/genconfig/tree/develop#readme). 

You'll notice also that the classes in `core.schema.xml` contain not only Attributes and Relationships as in the tutorial example above, but also Methods. If you look at the `Partition` class (l. 415) and scroll down a bit, you'll see a `get_all_applications` Method declared, along with its accompanying C++ declaration (as well as Java declaration, but we ignore this). The implementation of `get_all_applications` needs to be done manually, however, and is accomplished on l. 1301 of `src/algorithms.cpp`. If you scroll to the top of that file you'll see a `#include "dal/Partition.hpp"` line. In the actual dal repo, there's no such include file. However, assuming you followed the build instructions at the top of this document, you'll find it in the `build/` area of your work area, as the header was in fact generated. 

To see the `get_all_applications` function in action, you can do the
following. 
```
dal_dump_app_config -d oksconfig:$DAL_SHARE/../bin/dal_testing.data.xml -p ToyPartition -s ToyOnlineSegment
```
...where `dal_testing.data.xml` is written specifically for testing dal's functionality. The output will look like the following:
```
Got 2 applications:
====================================================================================================================================================================
| num | Application Object                             | Host                      | Segment                        | Segment unique id | Application unique id    |
====================================================================================================================================================================
|   1 | ToyRunControlApplication@RunControlApplication | toyhost.fnal.gov@Computer | ToyOnlineSegment@OnlineSegment | ToyOnlineSegment  | ToyRunControlApplication |
|   2 | SomeApp@CustomLifetimeApplication              | toyhost.fnal.gov@Computer | ToyOnlineSegment@OnlineSegment | ToyOnlineSegment  | SomeApp                  |
====================================================================================================================================================================
```

Note that in the output, `Application Object`, `Host` and `Segment` are printed in the format `<object name>@<class name>` where the object is an instance of a class. Note also that `RunControlApplication` is an actual ATLAS class and not to be confused with the much simpler `RCApplication` from the tutorial above. 

Likewise, you can see a Python script which serves the same function,
but via calling Python bindings to C++ functions. We of course want
the output to be identical:
```
dal_dump_app_config.py -d oksconfig:$DAL_SHARE/../bin/dal_testing.data.xml -p ToyPartition -s ToyOnlineSegment
```
You can play around with `dal_dump_apps/dal_dump_apps.py`, pass the
`-h` argument to see your options. 

## Next Step

Now that we've learned a bit about OKS, let's take a look at the [GUI interfaces to OKS](https://github.com/DUNE-DAQ/dbe#readme)




-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: jcfreeman2_

_Date: Fri Jun 9 10:07:19 2023 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/dal/issues](https://github.com/DUNE-DAQ/dal/issues)_
</font>
