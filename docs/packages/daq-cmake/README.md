# daq-cmake

This package provides CMake support for DUNE-DAQ packages.

# Overview of how to create a new package

## Setting up a development area

To create a new package, you'll want to install a DUNE-DAQ development environment and then create a new CMake project for the package. How to install and build the DUNE-DAQ development environment is described [here](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/Compiling-and-running/).


## A package's subdirectory structure

To learn a bit more about how to structure your package so that it can be incorporated into the DUNE DAQ software suite, we'll play with a contrived package called "toylibrary". It's actually contained within a subdirectory of the daq-cmake repo; however, in order to be able to build toylibrary we'll want to copy it into the `./sourcecode` directory so the build system can work with it. Assuming you're already in the base directory of your development environment, do the following: 
```
git clone https://github.com/DUNE-DAQ/daq-cmake.git -b dunedaq-v2.4.0
mv daq-cmake/toylibrary sourcecode
rm -rf daq-cmake
```
You can now build it using the normal commands:
```
dbt-setup-build-environment  # Assumption is you've already sourced daq-buildtools' dbt-setup-env.sh 
dbt-build.sh --install
```
In terms of its actual functionality, it's pretty useless (it contains a class which can wrap an integer, and another class which can print that wrapped integer). However, its functionality is beside the point; toylibrary contains many features which DUNE DAQ packages have in common, in particular DUNE DAQ packages which provide a library other developers want to link against. For starters, take a look at the subdirectories, `ls sourcecode/toylibrary`:


* *src*: contains the source files meant to be built into the package's shared object library/libraries

* *include*: contains the headers users of your package should #include

* *unittest*: contains the [unit tests](https://en.wikipedia.org/wiki/Unit_testing) you write to ensure that your individual classes, functions, etc. behave as expected

* *test*: contains any applications or plugins you've written for the purpose of [integration testing](https://en.wikipedia.org/wiki/Integration_testing) - ensuring that your software components interact as expected

If your package contains applications intended not for testing but for the end user, you'd put the code for it in a subdirectory called `apps/`. toylibrary doesn't have this type of application, but, e.g., the appfwk package does. Similarly, plugins not intended for testing but for the end user would go in `plugins/`. 


## Coding rules

Along with having a standard directory structure, the C++ code itself in toylibrary conforms to the [DUNE C++ Style Guide](https://dune-daq-sw.readthedocs.io/en/latest/packages/styleguide/). Here, "style" doesn't mean whitespace and formatting, but rather, a set of Modern C++ best practices designed to make your code more robust against bugs, easier to extend, easier to reuse, etc. The DUNE C++ Style Guide is derived from the Google C++ Style Guide, but is greatly simplified and has been modified to be more appropriate to the DUNE DAQ project than Google's projects. Code which is merged into a package's git develop branch should be in conformance with the guide; while it's encouraged for code on a package's unmerged feature branches to also be in conformance, this is less important. 

## Your project's CMakeLists.txt file

Every DUNE DAQ package should have one and only one `CMakeLists.txt` file, in the base directory of the package's repo (not to be confused with the base directory of the overall development area). To learn a bit about what that `CMakeLists.txt` file should look like, let's take a look at `sourcecode/toylibrary/CMakeLists.txt`. Because CMake is widely used and extensively documented online, this documentation will primarily focus on DUNE-specific CMake functions. The full documentation of the DUNE-specific CMake functions for users can be found [here](CmakeFunctions.md). Depending on your learning style, however, you may find it easier to start learning about some of what these functions are capable of by reading on in this wiki. 

At the top of CMakeLists.txt: before doing anything else, we want to define the minimum version of CMake used (currently 3.12, which supports [modern CMake style](https://cliutils.gitlab.io/modern-cmake/)) as well as the name and version of the project. Concerning the version: it may not literally be the case that the code you're working with is exactly the same as the version-in-question's release code, because you may be on a feature branch, or there may have been commits to the develop branch since the last release. 
```
cmake_minimum_required(VERSION 3.12)
project(toylibrary VERSION 1.1.0)
```
Next, we want to make CMake functions written specifically for DUNE DAQ development available. Near the top of the file, you'll see the following:
```
find_package(daq-cmake REQUIRED)
```
This is how we ensure that the CMakeLists.txt file has access to the standard DUNE DAQ CMake functions previously mentioned. When `find_package` is called here it imports daq-cmake's `DAQ` CMake module. Note that by convention all functions/macros within the module begin with `daq_`, so as to distinguish them from functions/macros from CMake modules written outside of DUNE DAQ. 

The next step is to call a macro from the `DAQ` module which sets up a standard DUNE CMake environment for your CMakeLists.txt file:
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
daq_add_library(IntPrinter.cpp LINK_LIBRARIES ers::ers)
```
What `daq_add_library` does here is create the main project library. It looks in the project's `./src` subdirectory for a file called `IntPrinter.cpp`, which it then compiles and links against the ERS library. The result is output in the build area as a shared object library named after the project itself, in a subdirectory of the same name as that of the source file it used - `build/toylibrary/src/libtoylibrary.so`. When `--install` is passed to `./build_daq_software.sh`, as it was in the instructions above, this library in turn is installed in a subdirectory of the installation area called `toylibrary/lib64/libtoylibrary.so`. 

The next function you see called in the CMakeLists.txt file is `daq_add_application`:
```
daq_add_application( toylibrary_test_program toylibrary_test_program.cxx TEST LINK_LIBRARIES ${Boost_PROGRAM_OPTIONS_LIBRARY} toylibrary )
```
which searches in the projects' `test/apps/` subdirectory for a file called `toylibrary_test_program.cxx`, builds it, and links against the project's main library which we created via the previous `daq_add_library` command as well as a Boost library used to parse program input. The output application is named after the first argument to the function, `toylibrary_test_program`; it can be found in `build/toylibrary/test/apps/toylibrary_test_program`. Since "TEST" was selected, the application won't be placed in the install area despite `--install` being used. Note that if the "TEST" argument hadn't been supplied, along with the installation occuring, the build system would have looked in a subdirectory of the project called `apps/` rather than `test/apps/` for the source file. In this sense, `toylibrary_test_program` is an example of an integration test program of interest to a project's developers but not its users. 

Another function currently provided by the DAQ CMake module is `daq_add_unit_test`. Examples of this function's use can be found at the bottom of the `sourcecode/toylibrary/CMakeLists.txt` file, e.g.:
```
daq_add_unit_test(ValueWrapper_test)
```
If you pass this function a name, e.g., `MyComponent_test`, it will create a unit test executable off of a source file called `sourcecode/<your packagename>/unittest/MyComponent_test.cxx`, and handle linking in the Boost unit test dependencies. You can also optionally have it link in other libraries by providing them after the `LINK_LIBRARIES` argument as in other functions; in the above example, this isn't needed because ValueWrapper is a template class which is instantiated within the unit test code itself.   

At the bottom of CMakeLists.txt, you'll see the following function:
```
daq_install()
```
When you call it it will install the targets (executables, shared object libraries) you wish to make available to others who want to use your package in a directory called `<your installation directory>/<pkgname>` (by default that would be `./install/toylibrary`). You'll also need to add a special file to your project for this function to work; this is discussed more fully in the "Installing your project as a local package" section later in this document. 

## In-depth documentation of the DUNE DAQ CMake functions

...can be found [here](CmakeFunctions.md)

## If your package relies on nonstandard dependencies

...go back and take a look at the "Adding extra UPS products and product pools" section of [the daq-buildtools documentation](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/Compiling-and-running/)

## Installing your project as a local package

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
curl -O https://raw.githubusercontent.com/DUNE-DAQ/daq-cmake/dunedaq-v2.4.0/configs/Config.cmake.in
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
dbt-build.sh --install 
```

without receiving an error message informing you that installation isn't an option. 

# Description of the CMake functions provided by `daq-cmake`

## daq_setup_environment:
Usage:  

```
daq_setup_environment()
```

This macro should be called immediately after this DAQ module is
included in your DUNE DAQ project's CMakeLists.txt file; it ensures
that DUNE DAQ projects all have a common build environment. It takes 
no arguments. 

## daq_codegen:
Usage:  
```
daq_codegen( <schema filename> [TEST] [DEP_PKGS <package 1> ...] [MODEL <model filename>] 
             [TEMPLATES <template filename1> ...] )
```

`daq_codegen` takes the schema files (without path) and uses `moo` to generate C++ headers from the templates.

Arguments:
   `<schema filenames>`: The list of schema files to process from `<package>/schema/<package>`. 
   Each schema file will applied to each template (specified by the TEMPLATE argument).
   Each schema/template pair will generate a code file in 
      `build/<package>/codegen/include/<schema basename>/<template basename>`
   e.g. `myschema.jsonnet` (from my_pkg) + `your_pkg/YourStruct.hpp.j2` will result in
       `build/codegen/my_pkg/my_schema/YourStruct.hpp`

   `TEST`: If the code is meant for an entity in the package's `test/` subdirectory, "TEST"
     should be passed as an argument, and the schema file's path will be assumed to be
     "test/schema/" rather than merely "schema/". 

   `DEP_PKGS`: If schema, template or model files depend on files provided by other DAQ packages,
     the "DEP_PKGS" argument must contain the list of packages.

   `MODEL`: The MODEL argument is # optional; if no model file name is explicitly provided,
     omodel.jsonnet from the moo package itself is used.

   `TEMPLATES`: The list of templates to use. This is a mandatory argument. The template file format is 
       `<template package>/<template name>.j2`
     If `<template package>` is omitted, the template is expected to be made available by moo.

## daq_add_library:
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
`daq_add_library(MyProj.cpp *Utils.cpp LINK_LIBRARIES ers::ers)` 
will create a library off of `src/MyProj.cpp` and any file in `src/`
ending in "Utils.cpp", and links against the ERS (Error Reporting
System) library

Public headers for users of the library should go in the project's
`include/<project name>` directory. Private headers used in the
library's implementation should be put in the `src/` directory.

## daq_add_plugin:
Usage:  
```
daq_add_plugin( <plugin name> <plugin type> [TEST] [LINK_LIBRARIES <lib1> ...])
```

`daq_add_plugin` will build a plugin of type `<plugin type>` with the
user-defined name `<plugin name>`. It will expect that there's a file
with the name `<plugin name>.cpp` located either in the `plugins/`
subdirectory of the project (if the `TEST` option isn't used) or in
the `test/plugins/` subdirectory of the project (if it is). Note that if the
plugin is deemed a "TEST" plugin, it's not installed as the
assumption is that it's meant for developer testing. Like
daq_add_library, daq_add_plugin can be provided a list of libraries
to link against, following the `LINK_LIBRARIES` argument. 

Your plugin will look in `include/` for your project's public headers
and `src/` for its private headers. Additionally, if it's a "TEST"
plugin, it will look in `test/src/`.

## daq_add_application

Usage:  
```
daq_add_application(<application name> <file | glob expression> ... [TEST] [LINK_LIBRARIES <lib1> ...])
```

This function is designed to build a standalone application in your
project. Its first argument is simply the desired name of the
executable, followed by a list of filenames and/or file glob
expressions meant to build the executable. It expects the filenames
to be either in the `apps/` subdirectory of the project, or, if the
"TEST" option is chosen, the `test/apps/` subdirectory. Note that if
the plugin is deemed a "TEST" plugin, it's not installed as the
assumption is that it's meant for developer testing. Like
daq_add_library, daq_add_application can be provided a list of
libraries to link against, following the `LINK_LIBRARIES` token.

Your application will look in `include/` for your project's public
headers and `src/` for its private headers. Additionally, if it's a
"TEST" plugin, it will look in `test/src/`.

## daq_add_unit_test
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

## daq_install
Usage:  
```
daq_install()
```

This function should be called at the bottom of a project's
`CMakeLists.txt` file in order to install the project's targets. It takes no
arguments.

# Schemas and code generation

`daq-cmake` supports for schema distribution and code generation with [moo](https://github.com/brettviren/moo/)





1. Schemas (jsonnet), models (jsonnet) and templates (jinjia) in the `schema/<package name>` folder are automatically copied to the installation driector and into ups products eventually.




1. The `daq_codegen` cmake function provides a simpliefied interface to `moo render` to generate C++ files from jinjia templates. It provides a mechanism to easily import schemas, templates or models from other packages and implements an out-of-date dependency check.

## Schema files

`daq-cmake` handles schemas in a similar fashion to C++ headers. Where header files are located according to the namespace of the class they declare (e.g. `mypkg::MyClass` in `include/mypkg/MyClass.hpp`, schemas location in the package is determined by the schema path (e.g. `mypkg.myschema` in `schema/mypkg/myschema.jsonnet`). In both cases the package name is integral part of the namespace/path to ensure uniqueness of the declared entities.

As an example, below is shown the organizarion of the `appfwk/schema` folder:

```txt
appfwk/
├── apps
├── cmake
├── CMakeLists.txt
├── doc
├── include
├── python
├── README.md
├── schema
│   ├── appfwk
│   │   ├── appinfo.jsonnet
│   │   ├── app.jsonnet
│   │   └── cmd.jsonnet
│   ├── README.md
│   └── README.org
├── src
├── test
└── unittest
```

`cmd.jsonnet` declares `dunedaq.appfwk.cmd` schema structures with the following statement

```jsonnet
local s = moo.oschema.schema("dunedaq.appfwk.cmd");
```

The same applies to `app.jsonnet` and `appinfo.jsonnet` for `dunedaq.appfwk.app` and `dunedaq.appfwk.appinfo` respectively.

The matching between the schema file name/path and the jsonnet namespace is essential for code generaton with `daq-cmake`. A mismatch between the two will result in empty generated files in most of the cases.

## Code generation with `daq_codegen`

`daq-cmake` provides the `daq_codegen` function to convert schema files to C++ entitites based on a model and a template. The function arguments are
```
daq_codegen( <schema files> [TEST] [DEP_PKGS <package 1> ...] [MODEL <model filename>] 
             [TEMPLATES <template filename1> ...] )
```
and the full reference is available [here](CmakeFunctions.md).  
These are its key features:

- `daq_codegen` assumes that schema files are located in `schema/mypkg`
- One or more template files must be defined.
- The path of the generated C++ headers is a combination of the schema path and the template name:  
  `mypkg.myschema` applied to `MyTemplate.hpp.j2` will result in `include/mypkg/myschema/MyTemplate.hpp.j2`.  
    **NOTE** The schema filename is converted to lowercase
- Templates are specified as `<template package>/<template name .j2>`. If `<template package>` is omitted, a moo template will be assumed. Othewise `daq_codegen` will search for the template file in `<template package>/<template name .j2>`


## Upgrade guide

### Schema files





1. Create the `schema/<package>` directory and move existing schema files in there




2. Rename the schema file according to the schema path

e.g. `schema/appfwk-cmd-schema.jsonnet` to `schema/appfwk/cmd.jsonnet`

### CMakeList.txt





1. Remove `SCHEMA` from `daq_add_plugin(...)` if it's used




2. Add `daq_codegen(...)` with appropriate parameters. In most of the cases the following should work
   ```
   daq_codegen(*.jsonnet TEMPLATES Struct.hpp.j2 Nljs.hpp.j2)
   ```

### config.cmake.in





1. Add the following lines to `<pkg>Config.cmake.in`:

```
add_library(@PROJECT_NAME@::@PROJECT_NAME@ ALIAS @PROJECT_NAME@)
   
+ get_filename_component(@PROJECT_NAME@_DAQSHARE "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
  
else()
```
   
   and
   
```
include(${targets_file})
   
+ set(@PROJECT_NAME@_DAQSHARE "${CMAKE_CURRENT_LIST_DIR}/../../../share")
   
endif()
```




-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu May 20 10:12:50 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-cmake/issues](https://github.com/DUNE-DAQ/daq-cmake/issues)_
</font>
