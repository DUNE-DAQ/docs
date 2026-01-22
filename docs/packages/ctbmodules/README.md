# ctbmodules - DUNE DAQ module to control and read out the CTB hardware

Ported from original implementation in redmine:

<https://cdcvs.fnal.gov/redmine/projects/dune-artdaq/repository/revisions/develop/show/dune-artdaq/Generators/pennBoard>

<https://cdcvs.fnal.gov/redmine/projects/dune-artdaq/repository/revisions/develop/entry/dune-artdaq/Generators/TriggerBoardReader_generator.cc>

<https://cdcvs.fnal.gov/redmine/projects/dune-artdaq/repository/revisions/develop/entry/dune-artdaq/Generators/TriggerBoardReader.hh>


## Instructions to update the configuration and run with dunedaq v5 line

### Area setup
First of all you need a v5 area. 
To do this follow the instructions in the daqconf wiki, for example [fddaq-v5.3.2](https://github.com/DUNE-DAQ/daqconf/wiki/Setting-up-a-fddaq%E2%80%90v5.3.2-software-area). 

Locally, in the top area, you also need the [base configuration repository](https://gitlab.cern.ch/dune-daq/online/ehn1-daqconfigs).
Please note that the repo on gitlab are only accessible via ssh key, so please register one in the CERN gitlab. 
I recommend you also set in your area a `.netrc` file as in the `np04daq` home, remember to change login to your CERN username. 
After that you can simply
```bash
git clone ssh://git@gitlab.cern.ch:7999/dune-daq/online/ehn1-daqconfigs.git
```
Or alternatively
```bash
cpm-setup -b fddaq-v5.3.2 ehn1-daqconfigs
```
The first one is a direct clone, while the second sets up the configuration repo to do some more advance operation, so the default branches might be a little strange. 
Further domentation on the various `cpm-*` commands can be found in [the runconftools documentation](https://github.com/DUNE-DAQ/runconftools/blob/develop/docs/README.md). 
The second only works if you have setup the `.netrc` file correctly.
To conclude, just 
```bash
source ehn1-daqconfigs/setup_db_path.sh 
```

### Update the CTB configuration
The ehn1-daqconfigs contains already a valid configuration for the CTB. 
Due to the implementation of HLTs and LLTs as confmodel::resource, it's best if any branch of ehn1-daqconfigs contains only one version of each. 
So, as CTB experts the only thing you should do is to update the value of the objects already created in ehn1-daqconfigs. 

In order to do so, there is a script called `update_ctb_settings`. 
Typical usage is:
```bash
update_ctb_settings ehn1-daqconfigs/sessions/np02-session.data.xml <your_json_file> 
```
This will do the following:
 - It will change the value of every objects in the configuration related to the CTB according to the the json file you provide
 - It will enable/disable HLTs and LLTs according to your configuration
Please keep in mind that HLTs can also be enabled/disabled via the shifter interface (see dedicated section).

Once you are happy with the changes, you can commit and push the changes on a branch on ehn1-daqconfigs and open a Merge request toward the dedicate branch. 

### Run the CTB configuration
in order to run, start using the shifter interface in local mode:
```bash
runconf-shifter-ui -l -d ehn1-daqconfigs
```
From the inerface select which components you need, select which HLTs you want to enable and click `create`. 
The output of the shifter interface will tell you how to run. 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Marco Roda_

_Date: Wed Jun 18 11:19:38 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/ctbmodules/issues](https://github.com/DUNE-DAQ/ctbmodules/issues)_
</font>
