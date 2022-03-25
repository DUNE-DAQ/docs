# InstructionsForCasualUsers
The intention of this page is to provide a few simple instructions that new or casual users can use to quickly demonstrate the operation of a small DAQ system that uses emulators instead of real electronics.

The steps fall into a few general categories (setup the environment, generate the sample system configuration, and use _nanorc_ to run the sample system), and they draw on more detailed instructions from other repositories, for example, _[daq-buildtools](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/)_ and _[nanorc](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/)_.

Here are the steps that should be used when you first create your local software working area (i.e. `<work_dir>`):



1. log into a system that has access to `/cvmfs/dunedaq.opensciencegrid.org/`


2. `source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh`


3. `setup_dbt dunedaq-v2.8.0`


4. `dbt-create.sh dunedaq-v2.8.0 <work_dir>`


5. `cd <work_dir>`


6. `dbt-workarea-env`


9. download a raw data file, either by running
   "`curl -o frames.bin -O https://cernbox.cern.ch/index.php/s/7qNnuxD8igDOVJT/download`"
   or clicking on the [CERNBox link](https://cernbox.cern.ch/index.php/s/7qNnuxD8igDOVJT/download)) and put it into `<work_dir>`


11. `daqconf_multiru_gen -d ./frames.bin -o . -s 10 daq_fake`


12. `nanorc daq_fake boot init conf start 101 wait 2 resume wait 60 pause wait 2 stop scrap terminate`


13. examine the contents of the HDf5 file with commands like the following:
    * `h5dump-shared -H -A swtest_run000101_0000_*.hdf5`
    * and
    * `python3 $DFMODULES_FQ_DIR/dfmodules/bin/hdf5dump/hdf5_dump.py -p both -f swtest_run000101_0000_*.hdf5`

When you return to this work area (for example, after logging out and back in), you can skip the 'setup' steps in the instructions above.  For example:



1. `cd <work_dir>`


2. `source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh`


3. `setup_dbt dunedaq-v2.8.0`


4. `dbt-workarea-env`


7. `nanorc daq_fake boot init conf start 102 wait 2 resume wait 60 pause wait 2 stop scrap terminate`


More detailed explanations on how to create different configurations can be found in [Instructions for different configurations for first-time users](ConfigurationsForCasualUsers.md)

If and when you are ready to start looking at existing code and possibly modifying it, you can use steps like the following:



1. `cd <work_dir>`


2. `source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh`


3. `setup_dbt dunedaq-v2.8.0`


4. `dbt-workarea-env`


5. `cd sourcecode`


6. `git clone https://github.com/DUNE-DAQ/<package_name>.git -b develop`
    * e.g. `git clone https://github.com/DUNE-DAQ/dfmodules.git -b develop`
    * the full list of available repository is [here](https://github.com/orgs/DUNE-DAQ/repositories)


8. `cd ..`


9. `dbt-build.sh`


4. `dbt-workarea-env --refresh`


10. continue as described above...


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Pierre Lasorak_

_Date: Fri Feb 25 17:28:21 2022 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
