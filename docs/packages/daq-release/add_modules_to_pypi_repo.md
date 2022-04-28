# Adding new modules to the Pypi-repo

If you have `pip2pi` installed, you can simply do the following to add any modules from `pypi` or tarballs:



1. `pip2pi $PATH_TO_PYPI_REPO <pypi_module_name==version>`;

    * `$PATH_TO_PYPI_REPO/<new_module_name>.whl` will be added after this;

    * This is the recommended way to install any packages from pypi.org as `pip2pi` will handle the dependencies automatically;


3. For tarballs, you can simply copy them over to the `pypi-repo` directory (NOTE: this is to be used only on our self-brewed packages);

    * Remember to rename the tarball to `module-name_X.X.X.tar.gz` before the next step;


4. Run `dir2pi $PATH_TO_PYPI_REPO` to generate new index files:

    * `$PATH_TO_PYPI_REPO/simple/index.html` will have a new entry for the newly-added module;

    * A new subdirectory will be created as `$PATH_TO_PYPI_REPO/simple/<new module name>` which contains:

      * An `index.html`

      * symbolic links to the wheel or tarball files under `$PATH_TO_PYPI_REPO` for each version of this module.

## Installing `pip2pi`

If you do not have `pip2pi` available, you can do the following to install it. Note that the latest official version (more than 2 years old) of `pip2pi` does not work well with python3. We have a patched version available [here](https://github.com/dingp/pip2pi/archive/1.0.0.tar.gz).



1. setup python3, skip this step if you already have access to it:

   * `source /cvmfs/dune.opensciencegrid.org/dunedaq/DUNE/products/setup; setup python v3_8_3b`;


2. create and activate a virtual environment:

   * `python -m venv pypi-repo-venv`

   * `source pypi-repo-venv/bin/activate`


3. install `pip2py`:

   * `pip install https://github.com/dingp/pip2pi/archive/1.0.0.tar.gz`

Now you should have access to `pip2pi` and `dir2pi` commands. Next time, you can simply activate the virtual env for accessing these tools.


## Preapre the repo in staging area on docker-bd



1. The staging area including that for `pypi-repo` is under `/home/dingpf/cvmfs_dunedaq`;


2. Run `docker run --rm -it -v /home/dingpf/cvmfs_dunedaq:/cvmfs/dunedaq.opensciencegrid.org -v $PWD:/scratch dunedaq/sl7` to start a container;


3. Follow the instructions above to install `pip2pi`;


4. Follow the instruction above to add new packages to the repo.

## Publishing to cvmfs repo



1. Login as `cvmfsdunedaq` to `oasiscfs01.fnal.gov`;


2. Obtain a valid FNAL Kerberos ticket;


3. run `~/bin/dunedaq-sync pypi-repo` to publish the staging area on `docker-bd.fnal.gov`.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Pengfei Ding_

_Date: Thu Aug 12 11:30:51 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daq-release/issues](https://github.com/DUNE-DAQ/daq-release/issues)_
</font>
