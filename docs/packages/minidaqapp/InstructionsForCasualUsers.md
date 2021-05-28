# InstructionsForCasualUsers
The intention of this page is to provide a few simple instructions that new or casual users can use to quickly demonstrate the operation of a small MiniDAQ system that uses emulators instead of real electronics.

The expected steps will be something like the following


1. setup the environment


2. generate the sample system configuration


3. use _nanorc_ to run the sample system

There is a bit of a chicken-and-egg problem, though, because it will be best to document those steps once the v2.6.0 release is complete, and we want to provide some documentation before the release is ready.  

To help give a flavor of what is to come, here are the steps that one might use for a v2.4.0-based system:


1. log into a system that has access to `/cvmfs/dunedaq.opensciencegrid.org/`


2. `source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh`


3. `setup_dbt dunedaq-v2.4.0`


4. `dbt-create.sh dunedaq-v2.4.0 <work_dir>`


5. `cd <work_dir>`


6. `dbt-setup-runtime-environment`


7. download a raw data file ([CERNBox link](https://cernbox.cern.ch/index.php/s/VAqNtn7bwuQtff3/download)) and put it into `<work_dir>`


8. `git clone https://github.com/DUNE-DAQ/nanorc.git -b v1.0.0`


9. `pip install -r nanorc/requirements.txt`


10. `python -m minidaqapp.nanorc.mdapp_gen -d ./frames.bin -o . -s 10 mdapp_fake`


11. `./nanorc/nanorc.py mdapp_fake boot init conf start 101 wait 2 resume wait 60 pause wait 2 stop scrap terminate`


12. examine the contents of the HDf5 file with commands like the following:
    * `h5dump-shared -H swtest_run000101_0000_*.hdf5`


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: bieryAtFnal_

_Date: Wed May 26 15:36:49 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/minidaqapp/issues](https://github.com/DUNE-DAQ/minidaqapp/issues)_
</font>
