# daq-cmake

This package provides CMake support for DUNE-DAQ packages.

The documentation for this package is divided into four parts:
1) Instructions for `create_dunedaq_package`, a script which will generate a good deal of CMake/C++ code which is standard across all DUNE DAQ packages
2) A description of the standard structure and CMake build code in a DUNE DAQ package
3) A complete reference manual for the DUNE-DAQ-specific CMake functions developers can call in order to specify their package's build
4) A description of how we use schema in order to consistently define data structures

Note that this documentation assumes you have some familiarity with the [daq-buildtools package](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools) and know how to set up a development area and run commands to build code in it.

## The `create_dunedaq_package` script

A DUNE DAQ software package is composed of various types of software components - standalone applications, libraries, [DAQModules](https://dune-daq-sw.readthedocs.io/en/latest/packages/appfwk/), etc. Across the packages there are common ways these are implemented, whether as a result of our [official coding guidelines](https://dune-daq-sw.readthedocs.io/en/latest/packages/styleguide/) or simply through tradition. `create_dunedaq_package` takes advantage of these patterns and saves you work by generating much of the boilerplate code which makes up a DUNE DAQ package.

Before using `create_dunedaq_package`, you'll want to have some idea of what software components will make up your package, and what their names should be. While the only argument actually required by `create_dunedaq_package` is the name of your new package, it won't do much unless you provide it with options and arguments. You can see what these are by running `create_dunedaq_package -h`, reprinted here for your convenience.

Arguments and options:

`--main-library`: package will contain a main, package-wide library which other packages can link in

`--python-bindings`: whether there will be Python bindings to the main library. Requires the `--main-library` option as well.

`--daq-module`: for each "`--daq-module <module name>`" provided at the command line, the framework for a DAQModule will be auto-generated

`--user-app`: same as `--daq-module`, but for user applications

`--test-app`: same as `--daq-module`, but for integration test applications

`--config-generation`: whether to generate a script which itself will generate JSON code to create an application based on the package. Requires at least one `--daq-module` as well.

Note that some of these concepts, e.g. a user-oriented app vs. an app designed for integration tests of the package itself, are covered below in the [Overview of a DUNE DAQ package](#package_overview) section.

In the directory `create_dunedaq_package` is run out of, `create_dunedaq_package` will create a subdirectory named after your package if such a subdirectory doesn't exist. If a subdirectory with that name already _does_ exist, it should be empty with the possible exceptions of a `README.md` documentation file and/or a `.git/` version control directory. These exceptions allow you to run the script using as an argument the name of a new repo which you've cloned into your area. An example of using `create_dunedaq_package` would be the following (note you can horizontal-scroll the command below):
```
cd ./sourcecode  # If we were in the base of a development area
create_dunedaq_package --daq-module AFirstModule --config-generation --user-app an_app_for_users --user-app another_app_for_users --python-bindings --main-library thenewpackage
```
(Of course in real life please use better names for your package and its components than those in the example). If you were to `ls thenewpackage`, you would see that the script had set up several new directories for you, as well as a `CMakeLists.txt` file:
```
apps
cmake
CMakeLists.txt
docs
include
plugins
pybindsrc
python
schema
src
unittest
```
where most of the directories contain boilerplate code for the software components you requested. While you'd be able to build this boilerplate package if it were in the `sourcecode/` directory of a standard DUNE DAQ development environment, the new package's components do almost nothing, although in the case of DAQModules code is generated which provide an example of how to set a member variable via Run Control configuration. Nonetheless this boilerplate code will need to be replaced, filled in and extended by the package's developers. Also if you look at `CMakeLists.txt`, you'll see that many of the function calls you'd need will have been added, though generally missing the arguments you'd need to provide them so they would know what libraries to link against, e.g.:
```
daq_add_application(an_app_for_users an_app_for_users.cxx LINK_LIBRARIES ) # Any libraries to link in not yet determined
```
Obviously comments such as `# Any libraries to link in not yet determined` should be deleted when it becomes appropriate.

Note also that a unit test is automatically generated for you _which is designed to fail_. Developers are strongly encouraged to replace it with appropriate unit tests for their package, unless it's one of those rare packages which don't need unit tests, in which case the unit test functionality should be entirely stripped from the package.

If the `--config-generation` option is chosen, the script which gets produced is called `<your package>_gen`. You can pass it the `-h` option to see its arguments, but the main thing to know is that to pass it a set of arguments you'd want to do so via the `-c <JSON file>` argument. An example of such a JSON file can be found in `<your package>/scripts/<your package>_example_config.json` file which is produced after you've run `create_dunedaq_package` with the `--config-generation` option.

Assuming you're in the base of a development area [whose environment has been set up](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools) and have run the example `create_dunedaq_package` command above, you can now build your newly generated code and then try out the configuration generation script:
```
dbt-build
dbt-workarea-env
thenewpackage_gen -c ./sourcecode/thenewpackage/scripts/thenewpackage_example_config.json anewconfig
```
...where you can edit the values `num_afirstmodules` and `some_configured_value` in (a copy of) `thenewpackage_example_config.json` to generate a different configuration. Note that while this _legally_ runs in [`nanorc`](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/), it doesn't actually do anything -- in particular, the DAQ module(s) you've specified only set a member variable when configured, and don't communicate with anything.

Now that you know how to generate the boilerplate for a DUNE DAQ package, please read on for a more in-depth understanding of what a typical DUNE DAQ package looks like.

<a name="package_overview"></a>
## Overview of a DUNE DAQ package

### Setting up a development area

To create a new package, you'll want to install a DUNE-DAQ development environment and then create a new CMake project for the package as described in [in the daq-buildtools documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/).


### A package's subdirectory structure

To learn a bit more about how to structure your package so that it can be incorporated into the DUNE DAQ software suite, we'll play with a contrived package called "toylibrary". It's actually contained within a subdirectory of the daq-cmake repo; however, in order to be able to build toylibrary we'll want to copy it into the `./sourcecode` directory so the build system can work with it. Assuming you're already in the base directory of your development environment, do the following:
```
git clone https://github.com/DUNE-DAQ/daq-cmake
cd daq-cmake
git checkout v2.2.0   # v2.2.0 corresponds to the dunedaq-v3.2.0 release
cd ..
mv daq-cmake/toylibrary sourcecode
rm -rf daq-cmake
```
You can now build toylibrary like you would a standard DUNE DAQ package. Please note that if you do so, since toylibrary isn't an official DUNE DAQ package and isn't a git repository, you'll get a couple of warnings; unlike most warnings, you can disregard these. Specifically, these warnings are `Package "toylibrary" not provided to the daq_add_subpackages` and `warning: Not a git repository.` (and surrounding text).

In terms of its actual functionality, toylibrary is pretty useless (it contains a class which can wrap an integer, and another class which can print that wrapped integer). However, its functionality is beside the point; toylibrary contains many features which DUNE DAQ packages have in common, in particular DUNE DAQ packages which provide a library other developers want to link against. For starters, take a look at the subdirectories, `ls sourcecode/toylibrary`:


* *src*: contains the source files meant to be built into the package's shared object library/libraries

* *include*: contains the headers users of your package should #include

* *unittest*: contains the [unit tests](https://en.wikipedia.org/wiki/Unit_testing) you write to ensure that your individual classes, functions, etc. behave as expected

* *test*: contains any applications or plugins you've written for the purpose of [integration testing](https://en.wikipedia.org/wiki/Integration_testing) - ensuring that your software components interact as expected

* *pybindsrc* contains source files which expose C++ code to python via the `pybind11` library. In `toylibrary`, we have only one such source file, `toy_wrapper.cpp`. The file provides a Python interface to the `IntPrinter` and `ValueWrapper<int>` classes from main `toylibrary` library. `toy_wrapper.cpp` also implements several "toy" functions, `WindUp`, `WindDown`, and `PlayInts`, which are used to demonstrate how C++ code can also be exposed via Python sub-modules.

* *scripts* This directory is inteneded to hold executable scripts. In this case it contains the script, `toyscript.py`. The `python` script demonstrates how the C++ code exposed in `toy_wrapper.cpp` can be used from within `python`.

If your package contains applications intended not for testing but for the end user, you'd put the code for it in a subdirectory called `apps/`. toylibrary doesn't have this type of application, but, e.g., the appfwk package does. Similarly, plugins not intended for testing but for the end user would go in `plugins/`.


### Coding rules

Along with having a standard directory structure, the C++ code itself in toylibrary conforms to the [DUNE C++ Style Guide](https://dune-daq-sw.readthedocs.io/en/latest/packages/styleguide/). Here, "style" doesn't mean whitespace and formatting, but rather, a set of Modern C++ best practices designed to make your code more robust against bugs, easier to extend, easier to reuse, etc. The DUNE C++ Style Guide is derived from the Google C++ Style Guide, but is greatly simplified and has been modified to be more appropriate to the DUNE DAQ project than Google's projects. Code which is merged into a package's git develop branch should be in conformance with the guide; while it's encouraged for code on a package's unmerged feature branches to also be in conformance, this is less important.

### Your project's CMakeLists.txt file

Every DUNE DAQ package should have one and only one `CMakeLists.txt` file, in the base directory of the package's repo (not to be confused with the base directory of the overall development area). To learn a bit about what that `CMakeLists.txt` file should look like, let's take a look at `sourcecode/toylibrary/CMakeLists.txt`. Because CMake is widely used and extensively documented online, this documentation will primarily focus on DUNE-specific CMake functions. The full documentation of the DUNE-specific CMake functions for users can be found [below](#cmake_function_descriptions). Depending on your learning style, however, you may find it easier to start learning about some of what these functions are capable of by reading on without skipping.

At the top of `CMakeLists.txt`: before doing anything else, we want to define the minimum version of CMake used (currently 3.12, which supports [modern CMake style](https://cliutils.gitlab.io/modern-cmake/)) as well as the name and version of the project. Concerning the version: it may not literally be the case that the code you're working with is exactly the same as the version-in-question's release code, because you may be on a feature branch, or there may have been commits to the develop branch since the last release.
```
cmake_minimum_required(VERSION 3.12)
project(toylibrary VERSION 1.1.0)
```
Next, we want to make CMake functions written specifically for DUNE DAQ development available. Near the top of the file, you'll see the following:
```
find_package(daq-cmake REQUIRED)
```
This is how we ensure that the `CMakeLists.txt` file has access to the standard DUNE DAQ CMake functions previously mentioned. When `find_package` is called here it imports daq-cmake's `DAQ` CMake module. Note that by convention all functions/macros within the module begin with `daq_`, so as to distinguish them from functions/macros from CMake modules written outside of DUNE DAQ.

The next step is to call a macro from the `DAQ` module which sets up a standard DUNE CMake environment for your `CMakeLists.txt` file:
```
daq_setup_environment()
```
Among other things daq_setup_environment() will do the following:

* Enforce the use of standard, extension-free C++17

* Ensure all code within the project can find the project's public headers

* Allow our linter scripts to work with the code

* Have gcc use standard warnings

* Support the use of CTest for the unit tests

Next you'll see calls to CMake's [find_package](https://cmake.org/cmake/help/v3.17/command/find_package.html) function, which makes toylibrary's dependencies available. Comments in the file explain why the dependencies are selected.

Then, you'll see a call to a function called `daq_add_library`.
```
daq_add_library(IntPrinter.cpp LINK_LIBRARIES logging::logging)
```
What `daq_add_library` does here is create the main project library. It looks in the project's `./src` subdirectory for a file called `IntPrinter.cpp`, which it then compiles and links against the DUNE DAQ logging library. The result is output in the installation area (`$DBT_INSTALL_DIR`) as a shared object library named after the project itself, `toylibrary/lib64/libtoylibrary.so`.

The next function you see called in the CMakeLists.txt file is `daq_add_python_bindings`:
```
daq_add_python_bindings( toy_wrapper.cpp LINK_LIBRARIES ${PROJECT_NAME} )
```
which is a function designed to allow the binding of C++ code to python. To do so, it relies on the header only library, `pybind11`. The function expects to find the source files exposing the C++ code, in the package directory, `pybindsrc`. In this `toylibrary` case, we have specified that the bindings are located in the file `toy_wrapper.cpp`. The resulting compiled file will be called, `_daq_${PROJECT_NAME}_py.so`, and will be placed in the output installation subdirectory, `${PROJECT_NAME}/lib64/python/${PROJECT_NAME}`. Similarly to `daq_add_library`, `_daq_${PROJECT_NAME}_py.so` will be linked against the libraries specified after `LINK_LIBRARIES`. For how to import the exposed C++ in, see detailed description section. After the call of `daq_add_python_bindings`, you will see the call to the function `daq_add_application`.
```
daq_add_application( toylibrary_test_program toylibrary_test_program.cxx TEST LINK_LIBRARIES ${Boost_PROGRAM_OPTIONS_LIBRARY} ${PROJECT_NAME} )
```
which searches in the projects' `test/apps/` subdirectory for a file called `toylibrary_test_program.cxx`, builds it, and links against the project's main library which we created via the previous `daq_add_library` command as well as a Boost library used to parse program input. The output application is named after the first argument to the function, `toylibrary_test_program`; it can be found in `$DBT_INSTALL_DIR/toylibrary/test/bin/toylibrary_test_program`. Note that if the "TEST" argument hadn't been supplied, the build system would have looked in a subdirectory of the project called `apps/` rather than `test/apps/` for the source file.

Another function currently provided by the DAQ CMake module is `daq_add_unit_test`. Examples of this function's use can be found at the bottom of the `sourcecode/toylibrary/CMakeLists.txt` file, e.g.:
```
daq_add_unit_test(ValueWrapper_test)
```
If you pass this function a name, e.g., `MyComponent_test`, it will create a unit test executable off of a source file called `sourcecode/<your packagename>/unittest/MyComponent_test.cxx`, and handle linking in the Boost unit test dependencies. You can also optionally have it link in other libraries by providing them after the `LINK_LIBRARIES` argument as in other functions; in the above example, this isn't needed because ValueWrapper is a template class which is instantiated within the unit test code itself.

At the bottom of CMakeLists.txt, you'll see the following function:
```
daq_install()
```
When you call it it will install the targets (executables, shared object libraries) you wish to make available to others who want to use your package in a directory called `$DBT_INSTALL_DIR/<pkgname>` (by default that would be `./install/toylibrary`). You'll also need to add a special file to your project for this function to work; this is discussed more fully in the "Installing your project as a local package" section later in this document.

### Installing your project as a local package

Use the procedure described below in order to have your package installed. Once your package is installed, it means other packages can access the libraries, public headers, etc., provided by your package via CMake's `find_package` command, i.e.:
```
# If other users call this, they can use your code
find_package(mypackage)
```

For starters, you'll want to call the DAQ module's `daq_install()` function at the bottom of your CMakeLists.txt file, as described earlier in this document.

A major thing you should be aware of is that when you call CMake's `find_package` function, it will look for a file with the name `mypackageConfig.cmake` in a predetermined set of directories, including the one you defined (or allowed to default to `./install`) when you initially set up your development area as described elsewhere in the documentation. What a standard `mypackageConfig.cmake` file should look like with modern CMake is documented in many places on the web, but in order to make life as easy as possible there's a templatized version of this file in the daq-cmake package. Assuming you've got a `./sourcecode/mypackage` repo in your development area, you can do the following:
```
cd ./sourcecode/mypackage
mkdir cmake
cd cmake
curl -O https://raw.githubusercontent.com/DUNE-DAQ/daq-cmake/dunedaq-v2.6.0/configs/Config.cmake.in
mv Config.cmake.in mypackageConfig.cmake.in
```
and then let's look at the opening lines of `mypackageConfig.cmake.in`:
```

@PACKAGE_INIT@

include(CMakeFindDependencyMacro)

# Insert find_dependency() calls for your package's dependencies in
# the place of this comment. Make sure they match up with the
# find_package calls in your package's CMakeLists.txt file
```
The only part of this file you need to worry about is the "Insert find_dependency()..." comment. In place of this comment, you'll want to call CMake's `find_dependency` function (details [here](https://cmake.org/cmake/help/latest/module/CMakeFindDependencyMacro.html)) for each package that mypackage depends on; this ensures that developers who call `find_package(mypackage)` don't need to have explicit `find_package` calls on these dependencies.

You can see a simple example of this kind of file with `toylibrary/cmake/toylibraryConfig.cmake.in`.

Once you've edited this file as described, from the base of your development area you can then run
```
dbt-build
```

without receiving an error message informing you that installation isn't an option.

<a name="cmake_function_descriptions"></a>
## Description of the CMake functions provided by `daq-cmake`

### daq_setup_environment:
Usage:

```
daq_setup_environment()
```

This macro should be called immediately after this DAQ module is
included in your DUNE DAQ project's CMakeLists.txt file; it ensures
that DUNE DAQ projects all have a common build environment. It takes
no arguments.

<a name="daq_codegen_documentation"></a>
### daq_codegen:
Usage:
```
daq_codegen( <schema filename1> ... [TEST] [DEP_PKGS <package 1> ...] [MODEL <model filename>]
             [TEMPLATES <template filename1> ...] )
```

`daq_codegen` uses `moo` to generate C++ headers from schema files from `schema/<package>` applying
them to one or more templates.

Arguments:


* `<schema filename1> ...`:

  The list of schema files to process from `<package>/schema/<package>`. Each schema file will applied to each template (specified by the TEMPLATES argument). Each schema/template pair will generate a code file named `build/<package>/codegen/include/<package>/<schema minus *.jsonnet extension>/<template minus *.j2 extension>`
e.g. `my_schema.jsonnet` (from `my_pkg`) + `your_pkg/YourStruct.hpp.j2` will result in `build/my_pkg/codegen/include/my_pkg/my_schema/YourStruct.hpp`


* `TEST`:

   If the code is meant for an entity in the package's test/ subdirectory, `TEST` should be passed as an argument, and the schema file's path will be assumed to be
`test/schema/` rather than merely `schema/`.


* `DEP_PKGS`:

   If schema, template or model files depend on files provided by other DAQ packages, the `DEP_PKGS` argument must contain the list of packages.


* `MODEL`:

   The `MODEL` argument is optional; if no model file name is explicitly provided, `omodel.jsonnet` from the moo package itself is used.


* `TEMPLATES`:

   The list of templates to use. This is a mandatory argument. The template file format is `<template package>/<template name including *.j2 extension>`. If `<template package>` is omitted, the template is expected to be made available by moo.

### daq_add_library:
Usage:
```
daq_add_library( <file | glob expression 1> ... [LINK_LIBRARIES <lib1> ...])
```

`daq_add_library` is designed to produce the main library provided by
a project for its dependencies to link in. It will compile a group
of files defined by a set of one or more individual filenames and/or
glob expressions, and link against the libraries listed after
`LINK_LIBRARIES`. The set of files is assumed to be in the `src/`
subdirectory of the project.

As an example,
`daq_add_library(MyProj.cpp *Utils.cpp LINK_LIBRARIES logging::logging)`
will create a library off of `src/MyProj.cpp` and any file in `src/`
ending in "Utils.cpp", and links against the [logging library](https://dune-daq-sw.readthedocs.io/en/latest/packages/logging/)

Public headers for users of the library should go in the project's
`include/<project name>` directory. Private headers used in the
library's implementation should be put in the `src/` directory.

### daq_protobuf_codegen:
Usage:
```
daq_protobuf_codegen( <protobuf filename1> ... [GEN_GRPC] [DEP_PKGS <package 1> ...] )
```

Arguments:


* `<protobuf filename1> ...`: these arguments are the list of `*.proto` files for protobuf's "protoc" program to process from `<package>/schema/<package>`. Globs also allowed.


* `GEN_GRPC`: if you need to cgenerate gRPC prototype for the `*.proto` files.


* `DEP_PKGS`: if a `*.proto` file given depends on `*.proto files` provided by other DAQ packages, the `DEP_PKGS` argument must contain the list of packages.

Each `*.proto` file will have a C++ header/source file generated as well as a Python file.
The names of the generated files are the same as per the [ProtoBuf API](https://protobuf.dev/): `*.pb.h` and `*.pb.cc` for the C++ header and source, respectively.
gRPC files are of the form `*.grpc.pb.h` and `*.grpc.pb.cc`.
The header will be installed in the public include directory.
Code can link against the header in the form:
```C++
#include "<package>/<file_name>.pb.h"
```
The generated python file will be called `*_pb2.py` and will be installed in `lib64/python/<package>`.
The generated python file will be called `*_grpc_pb2.py` and will be installed in `lib64/python/<package>`.

The source file will be built as part of the main package library.
Its compilation will be done automatically, i.e. there is no need to add `*.pb.cc` in the `daq_add_library` directive of your package: `daq_protobuf_codegen` will suffice.

Two requirements for calling this function:
1) You need to call `find_package(Protobuf REQUIRED)` to make the protobuf library available
2) You also need to call `daq_add_library`, i.e., have a main package-wide library
3) You need to call `find_package(gRPC REQUIRED)` before calling this function if you have specified `GEN_GRPC`.

### daq_add_python_bindings:
Usage:
```
daq_add_python_bindings( <file | glob expression 1> ... [LINK_LIBRARIES <lib1> ...])
```

`daq_add_python_bindings` is designed to produce a library providing
a python interface to C++ code. It will compile a group
of files, which are expected to expose the desired C++ interface via `pybind11`.
The set of files is defined by a set of one or more individual filenames and/or
glob expressions, and link against the libraries listed after
LINK_LIBRARIES. The set of files is expected to be in the `pybindsrc`
subdirectory of the project.

As an example,
`daq_add_python_bindings(my_wrapper.cpp LINK_LIBRARIES ${PROJECT_NAME})`
will create a library from `pybindsrc/my_wrapper.cpp` and link against
the main project library which would have been created via daq_add_library

Please note that library shared object will be named `_daq_${PROJECT_NAME}_py.so`, and will be placed
in the `python/${PROJECT_NAME}` directory. You will need to have the corresponding init file,
`python/${PROJECT_NAME}/__init__.py` to import the appropiate componenets of the module.
See toylibrary for a working example.

### daq_add_plugin:
Usage:
```
daq_add_plugin( <plugin name> <plugin type> [TEST] [LINK_LIBRARIES <lib1> ...])
```

`daq_add_plugin` will build a plugin of type `<plugin type>` with the
user-defined name `<plugin name>`. It will expect that there's a file
with the name `<plugin name>.cpp` located either in the `plugins/`
subdirectory of the project (if the `TEST` option isn't used) or in
the `test/plugins/` subdirectory of the project (if it is). Like
daq_add_library, daq_add_plugin can be provided a list of libraries
to link against, following the `LINK_LIBRARIES` argument.

Your plugin will look in `include/` for your project's public headers
and `src/` for its private headers. Additionally, if it's a "TEST"
plugin, it will look in `test/src/`.

Note that if `cetlib` is a dependency of the package being built, it
will be automatically linked against the plugin.

### daq_add_application

Usage:
```
daq_add_application(<application name> <file | glob expression> ... [TEST] [LINK_LIBRARIES <lib1> ...])
```

This function is designed to build a standalone application in your
project. Its first argument is simply the desired name of the
executable, followed by a list of filenames and/or file glob
expressions meant to build the executable. It expects the filenames
to be either in the `apps/` subdirectory of the project, or, if the
"TEST" option is chosen, the `test/apps/` subdirectory. Like
daq_add_library, daq_add_application can be provided a list of
libraries to link against, following the `LINK_LIBRARIES` token.

Your application will look in `include/` for your project's public
headers and `src/` for its private headers. Additionally, if it's a
"TEST" plugin, it will look in `test/src/`.

### daq_add_unit_test
Usage:
```
daq_add_unit_test(<unit test name> [LINK_LIBRARIES <lib1> ...])
```

This function, when given the extension-free name of a unit test
sourcefile in `unittest/`, will handle the needed boost functionality
to build the unit test, as well as provide other support (CTest,
etc.). Like daq_add_library, daq_add_unit_test can be provided a
list of libraries to link against, following the `LINK_LIBRARIES`
token.

### daq_oks_codegen
Usage:
```
daq_oks_codegen(<oks schema filename1> ... [NAMESPACE ns] [DALDIR subdir] [DEP_PKGS pkg1 pkg2 ...])
```

`daq_oks_codegen` uses the genconfig package's application of the same
name to generate C++ and Python code from the OKS schema file(s)
provided to it.

Arguments:

  `<oks schema filename1> ...`: the list of OKS schema files to process from `<package>/schema/<package>`. 

 `NAMESPACE`: the namespace in which the generated C++ classes will be in. Defaults to `dunedaq::<package>`

 `DALDIR`: subdirectory relative to the package's primary include directory where headers will appear (`include/<package>/<DALDIR argument>`); default is no subdirectory

 `DEP_PKGS`: if a schema file you've provided as an argument itself includes a schema file (or schema files) from one or more other packages, you need to supply the names of the packages as arguments to DEP_PKGS. 

The generated code is automatically built into the package's main
library (i.e., you don't need to explicitly pass the names of the
generated files to `daq_add_library`). Note that you get an error if
you call `daq_oks_codegen` and don't also call `daq_add_library`. 


### daq_install
Usage:
```
daq_install()
```

This function should be called at the bottom of a project's
`CMakeLists.txt` file in order to install the project's targets. It takes no
arguments.

## Schemas and code generation

`daq-cmake` supports for schema distribution and code generation with [moo](https://github.com/brettviren/moo/)



1. Schemas (jsonnet), models (jsonnet) and templates (Jinja) in the `schema/<package name>` folder are automatically copied to the installation directory and into Spack products eventually.




1. The `daq_codegen` cmake function provides a simpliefied interface to `moo render` to generate C++ files from Jinja templates. It provides a mechanism to easily import schemas, templates or models from other packages and implements a time-related dependency check. Details are [above](#daq_codegen_documentation).

<a name="daq_cmake_schema"></a>
### Schema files

`daq-cmake` handles schemas in a similar fashion to C++ headers. Where header files are located according to the namespace of the class they declare (e.g. `mypkg::MyClass` in `include/mypkg/MyClass.hpp`, schemas location in the package is determined by the schema path (e.g. `mypkg.myschema` in `schema/mypkg/myschema.jsonnet`). In both cases the package name is integral part of the namespace/path to ensure uniqueness of the declared entities.

As an example, below is shown the organization of the `appfwk/schema` folder:

```txt
appfwk/
├── apps
├── cmake
├── CMakeLists.txt
├── docs
├── include
├── python
├── schema
│   ├── appfwk
│   │   ├── appinfo.jsonnet
│   │   ├── app.jsonnet
│   │   ├── cmd.jsonnet
│   ├── README.md
├── src
├── test
└── unittest
```

`cmd.jsonnet` declares `dunedaq.appfwk.cmd` schema structures with the following statement

```jsonnet
local s = moo.oschema.schema("dunedaq.appfwk.cmd");
```

The same applies to `app.jsonnet` and `appinfo.jsonnet` for `dunedaq.appfwk.app` and `dunedaq.appfwk.appinfo`.

The matching between the schema file name/path and the jsonnet namespace is essential for code generation with `daq-cmake`. A mismatch between the two will result in empty generated files in most of the cases.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Wed Nov 29 11:16:01 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-cmake/issues](https://github.com/DUNE-DAQ/daq-cmake/issues)_
</font>
