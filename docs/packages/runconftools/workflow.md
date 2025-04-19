# Workflow for configuration creation and update

This is an example on how changes in the base repository can happen. 

### Area setup
```bash
source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh
setup_dbt latest_v5
dbt-create fddaq-v5.2.2-a9 MyArea
cd MyArea/
source env.sh 
dbt-workarea-env 
dbt-build
git clone ssh://git@gitlab.cern.ch:7999/dune-daq/online/runconftools.git 
cd runconftools
pip install .
cd ..
```

At this point, you have a working environment with the tools necessary to propagate the changes to the operation repo once we are happy with the result. 
The next step is to have a local base configuration area to modify. 
The following starts from the configuration for the DAQ version `fddaq-v5.2.2-a9-1`. 
```bash
git clone ssh://git@gitlab.cern.ch:7999/dune-daq/online/ehn1-daqconfigs.git EHN1-configs 
cd EHN1-configs 
git checkout fddaq-v5.2.2 -b mroda/my_dev
```
At this point you can make the changes you need.

### Some suggestions 
If you need to develop a generator, I suggest you write the generator outside the local git repo so you can test the generator on the base.
In case it's not ok, use a simple git restore to return the repository to its initial state. 
Once you are happy with the generator, you can move the file inside the repo and add it to git.

### Push review and testing 
Whatever the changes you made, commit and push to a branch on the base repo.

```bash
git commit . -m "My dev"
git push origin mroda/my_dev
```

At this point you open the merge request towards the branch you started from, in this case `fddaq-v5.2.2`.
Before the merge things should be tested and reviewed, if possible. 
But the test depends on the type of changes. 
If you just added a generator but the OKS objects in the base are unchanged, then there is no need to test all the generators.
Assuming the new generator is tested by the developers, we can just merge.
If there are changes in the OKS objects, we need to test that the generators are still functioning correctly.
So before merging, I would test the generator doing the following:
```bash
cd ..   ##to go back to the previous level
mkdir TempTest ## to run the generator on a test area so local changes are not lost
cpm-update -b mroda/my_dev -r mroda-test --no-push TempTest 
```
Here you will see if the generators keep working correctly. 
You can even inspect all the generated branches. 

If you need to push the branches on operation so that they can be tested by a shifter, you can do that too. 
In this case simply push with:
```bash
cpm-update -b mroda/my_dev -r mroda-test --push-only TempTest
```
If the local area has served its purpose, just remove it:
```bash
rm -rf TempTest
```
All the changes are safe on remote repositories. 

If all the branches are ok on the operation side, then all is well and we can merge, if not, we need to fix the merge request.

### Regeneration of the operation branches
Once the merge is done we just need to recreate the operation branches for the patch, but this time we push to branches with the right version. 

Most likely this is an operation done by run coordinators. 

```bash
mkdir Temp
cpm-update -b fddaq-v5.2.2 -r fddaq-v5.2.2 Temp 
## please note that the specification of base and release at this point might be the defaults 
## And it might not be necessary to specify them.
rm -rf Temp 
```
If test branches were created on the operation remote repository, those should be deleted.



-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: MRiganSUSX_

_Date: Tue Apr 8 12:49:40 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/runconftools/issues](https://github.com/DUNE-DAQ/runconftools/issues)_
</font>
