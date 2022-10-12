# DAQ Object Schema 

## Introduction

In the DAQ we will have various entities (applications, services, etc)
which must share data objects. We describe the structure of these
objects with a (meta) data structure called a "schema". Schema is like
a "contract" honored by all that share objects which are derived from
or validated by a schema. From this schema we may also generate C++
structures, object serialization methods, structure documentation,
actual object instances and other artifacts.

Implementation of `appfwk::DAQModules` generally require some
configuration. The configuration comes from the end user or run control
and is an object that is governed by schema. This document gives a brief
"howto" showing how to provide the needed schema.

We now walk through how to write our own schema for a `DAQModule`.

Prepare
=======

For now we place our schema files in a `schema/` directory of the same
source package that holds our `DAQModule` implementation. For example,
in a package called `mypackage` with a module called `MyModule`
abbreviated as `mm` we might make:

```sh
$ cd mypackage/
$ mkdir schema
$ emacs schema/mypackage-mm-schema.jsonnet
```


**Note**: 
The exact file name is not critical. The example shows the current
convention.

The rest of this document will make use of the real
`FakeDataConsumerDAQModule` provided in `appfwk/test`.

## Jsonnet

Jsonnet language is like "JSON plus functions". It is a "pure
functional" language and is focused on making it easy to create
expressive data structures. Jsonnet is "small" language and to write
schema files one only needs to understand a fraction which will be
described below. The Jsonnet
[tutorial](https://jsonnet.org/learning/tutorial.html) and [standard
library](https://jsonnet.org/ref/stdlib.html) documentation are very
good resources for learning more.

Compiling a Jsonnet "program" thus results in a data structure and
typically output in JSON format. We may use the `jsonnet` or `moo` (or
other) command line programs to "compile" or otherwise consume the
Jsonnet code.

## Schema definition structure

Ultimately, our schema is defined as an **array of objects** where each
object describes a **type** and a type is an instance of a **schema
class**. We have a fixed set of schema classes to choose from. They
include: `number`, `string`, `record`, `sequence` and others. A full
list is given in the [moo object
schema](https://brettviren.github.io/moo/oschema.html#outline-container-concepts)
page. One particular type may **refer** to other types. For example, a
`record` is composed of `fields` each of which references their type.
Although we end up with an **array of types**, in order to easily
reference, we will first make an intermediate **object of types**.

## Schema Preamble

We start out by importing helper code from `moo`:

``` {.jsonnet}
local moo = import "moo.jsonnet";
```

Then we define the base "path" and make a "schema factory" object
rooted on that path:

``` {.jsonnet}
local ns = "dunedaq.appfwk.fdc";
local s = moo.oschema.schema(ns);
```


**Note**:
These variables are `local` meaning they will not be directly accessible
by other Jsonnet files that may use this file. But they can be simply
referenced elsewhere in the file.

The `ns` variable holds a "base path" for our schema types. As may be
guessed, this maps to a C++ `namespace` when the schema is used to
generate C++ code. A "path" is also used in the Jsonnet to refer to a
type that may be defined elsewhere. Every type will carry its path in a
`.path` attribute.

## Schema body

We now get to the main body of the schema definition

``` {.jsonnet}
local fdc = {

    size: s.number("Size", "u8",
                   doc="A count of very many things"),

    count : s.number("Count", "i4",
                     doc="A count of not too many things"),

    conf: s.record("Conf",  [
        s.field("nIntsPerVector", self.size, 10,
                doc="Number of numbers"),
        s.field("starting_int", self.count, -4,
                doc="Number to start with"),
        s.field("ending_int", self.count, 14,
                doc="Number to end with"),
        s.field("queue_timeout_ms", self.count, 100,
                doc="Milliseconds to wait on queue before timing out"),
    ], doc="Fake Data Consumer DAQ Module Configuration"),

};
```

This temporary `fdc` object holds three types. When referred to by the
local attribute keys they are:

`size`:   a `number` of Numpy-style dtype `"u8"`

`count`:   another `number` of dtype `"i4"`

`conf`:   a `record` with various fields, each with a type

A few things to note about the types:

-   a type has a name given as the first argument to its construction
    function
-   a type may have a `doc` which is a short description
    ("docstring").

The type held in the `conf` key is a `record` named `Conf` (fully
qualified, `dunedaq.appfwk.fdc.Conf`). A `record` holds an array of
fields. Each `field` itself has a type which is specified as a reference
by naming an attribute key, eg `self.count`. Fields may also be given a
`doc`.

## Finishing the schema

We now come to the last line in our Jsonnet program which prepares our
final **array of types**. It is:

``` {.jsonnet}
moo.oschema.sort_select(fdc, ns)
```

The `fdc` is our temporary working object and the `ns` is again the
"base path" defined at the top of the file. The `sort_select()`
function will:

-   perform a [topological
    sort](https://en.wikipedia.org/wiki/Topological_sorting) on the
    graph formed by the types and any type references they hold
-   return the sorted list with any types that reside outside the "base
    path" removed.

## Compiled result

Normally we will leave the schema in this Jsonnet form as `moo` can read
it directly. It is sometimes instructive to see the result of
"compiling" the Jsonnet program to JSON. It is also important to do
this frequently while developing the schema to assure there are no
syntax or other errors. Here is one command to run and its full JSON
output:


```json
[
    {
        "deps": [],
        "doc": "A count of very many things",
        "dtype": "u8",
        "name": "Size",
        "path": [
            "dunedaq",
            "appfwk",
            "fdc"
        ],
        "schema": "number"
    },
    {
        "deps": [],
        "doc": "A count of not too many things",
        "dtype": "i4",
        "name": "Count",
        "path": [
            "dunedaq",
            "appfwk",
            "fdc"
        ],
        "schema": "number"
    },
    {
        "deps": [
            "dunedaq.appfwk.fdc.Size",
            "dunedaq.appfwk.fdc.Count",
            "dunedaq.appfwk.fdc.Count",
            "dunedaq.appfwk.fdc.Count"
        ],
        "doc": "Fake Data Consumer DAQ Module Configuration",
        "fields": [
            {
                "default": 10,
                "doc": "Number of numbers",
                "item": "dunedaq.appfwk.fdc.Size",
                "name": "nIntsPerVector"
            },
            {
                "default": -4,
                "doc": "Number to start with",
                "item": "dunedaq.appfwk.fdc.Count",
                "name": "starting_int"
            },
            {
                "default": 14,
                "doc": "Number to end with",
                "item": "dunedaq.appfwk.fdc.Count",
                "name": "ending_int"
            },
            {
                "default": 100,
                "doc": "Milliseconds to wait on queue before timing out",
                "item": "dunedaq.appfwk.fdc.Count",
                "name": "queue_timeout_ms"
            }
        ],
        "name": "Conf",
        "path": [
            "dunedaq",
            "appfwk",
            "fdc"
        ],
        "schema": "record"
    }
]
```


**Warning**:
Never edit this JSON file nor any other generated files. Besides being
painful to edit JSON compared to Jsonnet, it is the Jsonnet that is
definitive. It is used in other contexts so editing the JSON will break
the contract that the schema represents. In other words: if you edit the
JSON you\'ll likely crash the DAQ!


## Code generating

One primary purpose of schema is to generate code. This is done by using
`moo` to apply the schema data structure to a *template* file. The
template file is essentially a code file (eg, a C++ header file) with
additional markup in a meta language (`moo` uses Jinja2).

Currently, for each schema we generate two code files.

struct:   a C++ header file with C++ `struct` and `using` type aliases for
    each type in our schema.

nljs:   short for `nlohmann::json` and a C++ header file holding `to_json()`
    and `from_json()` function definitions that allow serialization of
    the types defined in **struct**.


**Warning**:
Running the code generator will be integrated into our CMake build.
Until that support is ready we will generate code somewhat manually with
the help of a little `schema/generate.sh` script that will be customized
to each package and using the one provided by `appfwk` as a starting
point.

Also until we integrate the codegen with CMake we will actually commit
the generated headers to the source repository so that builds will be
successful. Normally, one should **not** commit generated files to code
repositories and we will cease doing this when CMake integration is
ready.

Although it is easy to run `generate`, the developer **must** remember
to re-run it each time any change to a schema is made in order that the
generated files are updated. The rest of this section describes the
`generate.sh` used in `appfwk`.


An example of a `moo` command line for code generation is:

```sh
moo -g /lang:ocpp.jsonnet \                     # 1
    -M /home/bv/dev/moo/examples/oschema \      # 2
    -T /home/bv/dev/moo/examples/oschema \      # 3
    -M /home/bv/dev/dune-daq/sv/appfwk/schema \ # 4
    -A path=dunedaq.appfwk.fdc \                # 5
    -A ctxpath=dunedaq \                        # 6
    -A os=appfwk-fdc-schema.jsonnet \           # 7
  render omodel.jsonnet ostructs.hpp.j2 \       # 8
                                        \       # 9
  > /home/bv/dev/dune-daq/sv/appfwk/test/appfwk/fdc/Structs.hpp
```

Some implementation details are exposed in this example and the develop
need not attempt to understand everything but for completeness the
command line is explained.



1.  we "graft" on some supporting utility Jsonnet function provided by
    `moo` at a location in the "model" (see note below)


2.  set a path in which to find models (Jsonnet files)


3.  set a path in which to find templates (Jinja files)


4.  find our schema files


5.  Set a "top-level argument" (TLA) `path` which names the a "base
    path"


6.  Set a TLA which names a "context path"


7.  Set a TLA to provide our schema


8.  The `render` command applies the model (first file) to the template
    (second file)


9.  The output of this is then redirected by `generate.sh` to a header
    file.


**Note**:
A "model" is an overall data structure in a form expected by the
template. We use a model called `omodel.jsonnet` which defines a Jsonnet
top-level function which expects to receive our schema data structure as
a top-level argument (TLA). Thus the model\'s function "glues" our
schema data structure into the structure that is actually required by
the template.

## Object generating

The codegen schema described above satisfies the "consumer" end of a
contract. We must also satisfy a "producer" end when we create actual
command objects. That is, we must be able to produce a data structure
such when fed through the processing inside `appfwk` the right bits pop
out to our `DAQModule` configuration handling method.


**Warning**:
How we best do this is still in development. Eventually we will have a
"configuration editor" application. What follows is just one way to do
things with Jsonnet. A Python-centric approach is also under
development.

The main `appfwk` program `daq_application` accepts a **command
sequence** which is simply a number of **command objects** consumed in
some serial fashion. Many interfaces for consuming command objects exist
and are in development (file based, HTTP/REST server based).

Each command object is composed of an ID (`init`, `conf`, etc) and a
payload. The structure of the payoad depends on the command ID. In some
commands (notably `conf`) a portion of the payload is "addressed" to
be delivered to an instance of our `DAQModule` and the structure of this
portion is governed by the schema we wrote above.

To help make correct command objects, we may use a set of Jsonnet
functions. These reflect the structure of schema. We\'ll focus on a job
called "fdpc" which combines two `DAQModule` instances: one of the
`FakeDataProducerDAQModule` implementation and one of
`FakeDataConsumerDAQModule`.

Here, we build our command sequence as a JSON Array (a JSON Stream is
also possible). Let\'s walk through the Jsonnet defining the sequence.

First the preamble


``` {.jsonnet}
local moo = import "moo.jsonnet";

local cmd = import "appfwk-cmd-make.jsonnet";
local fdp = import "appfwk-fdp-make.jsonnet";
local fdc = import "appfwk-fdc-make.jsonnet";

local qname = "hose";            // the name of the single queue in this job
```

The `*-make.jsonnet` modules provide functions which reflect the schema.
The `cmd` schema governs the internals of `appfwk` while `fdp` and `fdc`
cover their associated `DAQModule` implementations. The `qname` is a
name of an `appfwk` Queue that is needed in a few places.

What follows is an array (`[...]`), each element is a command object
which we will take in turn.

``` {.jsonnet}
cmd.init([cmd.qspec("hose", "StdDeQueue", 10)],
         [cmd.mspec("fdp", "FakeDataProducerDAQModule",
                    cmd.qinfo(fdp.queue, qname, cmd.qdir.output)),
          cmd.mspec("fdc", "FakeDataConsumerDAQModule",
                    cmd.qinfo(fdc.queue, qname, cmd.qdir.input))]),
```

The `cmd.init()` function takes two arguments, a list of "queue specs"
and a list of "module specs". Instances of each speck type can be also
constructed with a corresponding function. The use of these functions
can catch some mistakes early.

A `qspec()` function returns an object defining an `appfwk` queue,
giving it a name, a "kind" and a capacity. A `mspec()` returns an
object holding information needed to instantiate and initialize a
`DAQModule` instance. A name and "kind" are given as well as one or a
list of "queue info" as returned by the `qinfo()` function. Queue info
is standardized information needed to locate a module\'s queue. The, eg,
`fdc.queue` gives a "label" which is also hard-wired into the
module\'s C++. The module can then associate this known label with the
`qname` (`"hose"` in this case). Finally a queue info is tagged as being
for an "input" or an "output" queue.

::: {.warning}
The module developer must write C++ code to make use of this queue info.
`appfwk` provides some helper functions. Most expected handling of this
information in the module C++ is expected to be very general and may
itself be provided as generated code in the future.
:::

We next continue to defining the `conf` command object.


``` {.jsonnet}
cmd.conf([cmd.mcmd("fdp", fdp.conf(10,-4,14)),
          cmd.mcmd("fdc", fdc.conf(10,-4,14))]),
```

The `cmd.mcmd()` wraps is arguments in the correct structure expected by
`appfwk` for the portion of a `conf` command payload meant for each
module. The main information is provided by the module-specific `make`
helpers, eg `fdc.conf()`. Let\'s look a that function:

``` {.jsonnet}
// Make a conf object for FDC
conf(nper, beg, end, toms=100) :: {
    nIntsPerVector: nper, starting_int: beg, ending_int: end,
    queue_timeout_ms: toms, 
},
```

You may compare this construction schema function to what is defined in
the corresponding codegen schema shows above to see it matches.


**Note**:
This construction schema function was hand-written. Means to
automatically define it based on codegen schema is a work in progress.

## Validating

Due to the nature of the `appfwk` code, the codegen schema must have
type-free breaks in the overall command object schema. Thus, using that
same schema to validate a command object will be weak (any data will fit
the "`any`" types). A more explicit **validation schema** is made as
an extension to the codegen schema.


**Warning**:
This is still a work in progress.


## Running

Finally, we may run something:

```sh
$ moo compile appfwk/schema/fdpc-job.jsonnet > fdpc-job.json
$ daq_application --commandFacility file://fdpc-job.json
```


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Alessandro Thea_

_Date: Tue Nov 17 13:06:14 2020 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/appfwk/issues](https://github.com/DUNE-DAQ/appfwk/issues)_
</font>
