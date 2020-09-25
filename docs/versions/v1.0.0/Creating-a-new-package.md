## Setting up a development area

To create a new package, you'll want to install a DUNE-DAQ development environment and then create a new CMake project for the package. How to install and build the DUNE-DAQ development environment is described [[here|Compiling-and-running]].

After installation of the development environment, you'll see that there are already two CMake projects installed, appfwk and ers (daq-buildtools, which provides CMake modules for DUNE DAQ developers, is not itself a CMake project). You'll also notice that `ers` and `appfwk` are git repos; you'll want your project to reside in a git repo as well. 

## The superproject CMakeLists.txt

Every project which is installed in your development area is actually a subproject of the `dune-day` CMake superproject. The superproject's `CMakeLists.txt` file is constructed when you run `quick-start.sh`, and resides in the directory out of which you ran it. The CMake code in that file globally influences the CMake code of each project which is a subdirectory; this influence includes:

* Ensuring that all code is compiled under extension-free, standard C++17
* Ensuring that a full set of standard compiler warnings are used
* Ensuring that the DUNE C++ code linters can work with your C++ code
* Ensuring that the CMake functions defined in `daq-buildtools/CMake/DAQ.cmake` are available to your CMake code
* Ensuring that you won't need to write any CMake code in order for your C++ code to find headers associated with Boost, or the appfwk or ers projects
* Providing two CMake variables, `DAQ_LIBRARIES_UNIVERSAL` and `DAQ_LIBRARIES_UNIVERSAL_EXE`, which define dependencies that any typical DUNE DAQ library (`DAQ_LIBRARIES_UNIVERSAL`) or executable (`DAQ_LIBRARIES_UNIVERSAL_EXE`) should link in

You'll also notice that the ers and appfwk projects are added in the superproject `CMakeLists.txt` via the passing of their namesake subdirectories to CMake's `add_subdirectory` command; once you have your project subdirectory, you'll want to add it to the superproject `CMakeLists.txt` file as well so it knows your work should be part of the overall build. 

## Your project's CMakeLists.txt file

If you're in the directory in which you ran `quick-start.sh`, you can look at `ers/CMakeLists.txt` and `appfwk/CMakeLists.txt` for examples of project CMakeLists.txt files. While a lot can be learned from looking at these examples and reading this documentation, realize that CMake is a full-blown programming language, and like any programming language, the more familiar you are with it the easier life will be. It's extensively documented online; in particular, if you want to learn more about specific CMake functions you can go [here](https://cmake.org/cmake/help/v3.17/manual/cmake-commands.7.html) for a reference guide of CMake commands, or, if you've sourced `setup_build_environment` (so CMake is set up), you can even learn at the command line via `cmake --help-command <name of command>`

However, on top of the CMake language itself, there are CMake functions which have been written specifically for DUNE DAQ development, and there's a structure your CMake code should follow; looking at `appfwk/CMakeLists.txt` is a good way to learn about both of these. Guidelines to follow are:

* There there should be only one CMakeLists.txt file in your project, and it should be in the base directory of your project. 

* It's recommended that you link the libraries defined by DAQ_LIBRARIES_UNIVERSAL into the libraries you create, and DAQ_LIBRARIES_UNIVERSAL_EXE into the executables you create.  An example of the latter is shown in the 'target_link_libraries' line below.

* You may also want to define a DAQ_LIBRARIES_PACKAGE CMake variable, which define additional libraries your package's executables and libraries should generally depend on

* CMake commands which are specific to the code in a subdirectory tree should be clustered in the same location, and they should be prefaced with the name of the subdirectory wrapped in the `point_build_to` CMake function. E.g., for the code in `appfwk/apps` we have:
```
point_build_to( apps )

add_executable(daq_application apps/daq_application.cxx)
target_link_libraries(daq_application ${DAQ_LIBRARIES_UNIVERSAL_EXE} ${DAQ_LIBRARIES_PACKAGE})
```
Here, `point_build_to(apps)` will ensure that the ensuing targets will be placed in a subdirectory of the `${CMAKE_BINARY_DIR}` directory (build directory) whose path mirrors the path of the source itself. To get concrete, this command means that after a successful build we'll have an executable, `./build/appfwk/apps/daq_application`, where that path is given relative to the base superproject directory. Without this function call it would end up as `./build/appfwk/daq_application`.

You'll also notice that we link in the `${DAQ_LIBRARIES_UNIVERSAL_EXE}` libraries defined in the superproject CMakeLists.txt, as well as libraries specific to the appfwk package, defined in DAQ_LIBRARIES_PACKAGE

The other function currently provided by the DAQ CMake module is `add_unit_test`. Examples of this function's use can be found at the bottom of the `appfwk/CMakeLists.txt` file. If you pass this function a name, e.g., `mytest`, it will create a unit test executable off of a source file called `unittest/mytest.cxx`, and handle linking in common libraries and the needed Boost unit test dependencies. If you're curious, you can find its implementation in `daq-buildtools/CMake/DAQ.cmake`, path relative to the superproject base directory. 

When you write code in CMake good software development principles generally apply. Writing your own macros and functions you can live up to the [Don't Repeat Yourself principle](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself); an example of this can be found in the definition of the `MakeDataTypeLibraries` macro, which helps avoid boilerplate while instantiating the FanOutDAQModule template class for various types and giving these instantiations well-motivated names. Note that this macro makes use of the `configure_file` command which lets you modify source files with CMake environment variables. 

Another thing to be aware of: since you're using a single CMakeLists.txt file, the scope of your decisions can extend to all ensuing code. So, e.g., if you add the line `link_libraries( bloated_library_with_extremely_common_symbol_names )` then all ensuing targets from `add_executable`, `add_library`, etc., will get that linked in. For this reason, prefer a target-specific call such as `target_link_libraries(executable_that_really_needs_this_library bloated_library_with_extremely_common_symbol_names)` instead. 

## setup_build_environment

As you've discovered from the Compiling-and-Running section you were pointed to at the start of this Wiki, `quick-start.sh`, along with constructing the superproject `CMakeLists.txt` file, also constructs a file called `setup_build_environment` which does what it says it's going to do. It performs ups setups of dependencies (Boost, etc.) which `ers` and `appfwk` rely on. If you have any new dependencies, you'll want to add them by looking for the `setup_returns` variable in `setup_build_environment`. You'll see there are several packages where for each package, there's a ups setup followed by an appending of the return value of the setup to `setup_returns`. You should do the same for each dependency you want to add, e.g.

```
setup <dependency_I_am_introducing> <version_of_the_dependency> # And perhaps qualifiers, e.g., -q e19:debug
setup_returns=$setup_returns"$? "
```

The `setup_build_environment` script uses `setup_returns` to check that all the packages were setup without a nonzero return value. 

You may also want to set up additional environment variables for your new project in `setup_build_environment`. 


