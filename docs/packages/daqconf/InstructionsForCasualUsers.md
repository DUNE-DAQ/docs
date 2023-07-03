# InstructionsForCasualUsers
The intention of this page is to provide a few simple instructions that new or casual users can use to quickly demonstrate the operation of a small DAQ system that uses emulators instead of real electronics.

The steps fall into a few general categories (setup the environment, generate the sample system configuration, and use _nanorc_ to run the sample system), and they draw on more detailed instructions from other repositories, for example, _[daq-buildtools](https://dune-daq-sw.readthedocs.io/en/latest/packages/daq-buildtools/)_ and _[nanorc](https://dune-daq-sw.readthedocs.io/en/latest/packages/nanorc/)_.

As of Oct-4-2022, here are the steps that should be used when you first create your local software working area (i.e. `<work_dir>`):



1. log into a system that has access to `/cvmfs/dunedaq.opensciencegrid.org/`


2. `source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh`


3. `setup_dbt latest-gcc12`


4. `dbt-create -c -b candidate rc-v3.2.0-2 <work_dir>`


6. `cd <work_dir>`


7. `dbt-workarea-env`


9. download a raw data file, either by running
   "`curl -o frames.bin -O https://cernbox.cern.ch/index.php/s/0XzhExSIMQJUsp0/download`"
   or clicking on the [CERNBox link](https://cernbox.cern.ch/index.php/s/0XzhExSIMQJUsp0/download)) and put it into `<work_dir>`


10. `git clone https://github.com/DUNE-DAQ/daq-systemtest`


11. `daqconf_multiru_gen --hardware-map-file daq-systemtest/config/default_system_HardwareMap.txt daq_fake`


12. `nanorc daq_fake ${USER}-test boot conf start_run 101 wait 60 stop_run shutdown`


13. examine the contents of the HDf5 file with commands like the following:

   * `h5dump-shared -H -A swtest_run000101_0000_*.hdf5`

   * and

   * `hdf5_dump.py -n 3 -p all -f swtest_run000101_0000_*.hdf5`

If you intend to run _nanorc_ on the Kubernetes cluster, then [these instructions](ConfigDatabase.md) may be useful.

When you return to this work area (for example, after logging out and back in), you can skip the 'setup' steps in the instructions above.  For example:



1. `cd <work_dir>`


2. `source ./dbt-env.sh`


4. `dbt-workarea-env`


7. `nanorc daq_fake ${USER}-test boot conf start_run 102 wait 60 stop_run shutdown`


More detailed explanations on what's going on with the steps above and how to create different configurations can be found in [Instructions for different configurations for first-time users](ConfigurationsForCasualUsers.md)

If and when you are ready to start looking at existing code and possibly modifying it, you can use steps like the following:



1. `cd <work_dir>`


2. `source ./dbt-env.sh`


4. `dbt-workarea-env`


5. `cd sourcecode`


6. `git clone https://github.com/DUNE-DAQ/<package_name>.git -b develop`

   * e.g. `git clone https://github.com/DUNE-DAQ/dfmodules.git -b develop`

   * the full list of available repository is [here](https://github.com/orgs/DUNE-DAQ/repositories)


8. `cd ..`


9. `dbt-build`


4. `dbt-workarea-env`


10. continue as described above...


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Jonathan Hancock_

_Date: Fri Jun 30 14:02:34 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
