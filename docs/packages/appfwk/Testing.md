# Testing
Broadly speaking, there are two types of test program you can run: unit tests, and integration tests. 

# Unit tests

Unit tests are standalone programs with names of the form `<code unit under test>_test` and are implemented in the ./unittest subdirectory of a package. They're written using the Boost.Test library. For complete documentation on the Boost.Test library, you can look at the [Boost documentation](https://www.boost.org/doc/libs/1_73_0/libs/test/doc/html/index.html); for substantially quicker but still useful intros, take a look [here](http://web.archive.org/web/20160524135412/http://www.alittlemadness.com/2009/03/31/c-unit-testing-with-boosttest/) and [here](https://www.ibm.com/developerworks/aix/library/au-ctools1_boost/index.html).

While you can run a unit test program without arguments, some arguments are very useful - in particular, those that control which test cases are run, and those that control the level of logging output. To maximize the output to screen, add the argument `-l all`, and to minimize it, add `-l nothing`. Other intermediate levels are covered in the Boost documentation. To skip a test, you can add an argument of the form `--run_test=\!test_you_dont_want`; note the exclamation point needs to be escaped with a backslash since the shell interprets it as a special character otherwise. 

# Integration tests

Integration tests look at how various units of code interact; unlike unit tests, there's no common approach to running them. As such, a list of integration tests and how to run them can be found in the list below:


* [Queue testing](Queue-testing.md)

* dummy_test_app: A simple application that statically instantiates a DummyModule DAQModule, which simply takes the command "stuff" to echo a string

* producer_consumer_dynamic_test.json: A sample configuration file for `daq_application` which runs a version of the [Simple readout application](Simple-readout-application.md)



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Apr 7 11:56:00 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/appfwk/issues](https://github.com/DUNE-DAQ/appfwk/issues)_
</font>
