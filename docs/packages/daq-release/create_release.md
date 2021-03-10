# create_release
# Creating a new DAQ release

## Overview

Here are the general steps of creating a new DAQ release.



1. Information gathering -- create an issue in `daq-release` repo to keep track of things ([example](https://github.com/DUNE-DAQ/daq-release/issues/31)):
    * release tag 
    * new python modules (and/or versions, same for below);
    * new DAQ packages;
    * new externals packages;
    * any other changes requiring actions before rolling out the new release;


2. Create a feature branch in `daq-release` repo and link it to the issue created in the previous step:
    * create a new release directory under `daq-release/configs`, by copying most recent release, e.g. `cp -pr daq-release/configs/dunedaq-v2.3.0 daq-release/configs/dunedaq-v2.4.0`;
    * modify `dbt-setttings.sh` (optional):
        * use `products` and `products_dev` in cvmfs directly (change `dune_products_dirs` list);
        * commenting out any DAQ packages (in `dune_daqpackages` list);
        * update `dune_externals` with new versions of external UPS packages if necessary (assuming you already prepared the new version of external packages, if not, refer to [How-to-build-external-UPS-packages](https://github.com/DUNE-DAQ/daq-release/blob/develop/doc/make_ups_products.md)).
    * modify `pyvenv_requirements.txt` with the updated list of required modules and versions (assuming any new modules or versions are already available in `pypi-repo` on cvmfs, otherwise, refer to [how-to-add-new-modules-to-pypi-repo](https://github.com/DUNE-DAQ/daq-release/blob/develop/doc/add_modules_to_pypi_repo.md) for instructions).
    * modify `dbt-build-order.cmake` (optional), if new DAQ packages will be included in the new release, modfiy this file to include them in the build-order list;
    * Come back later to modify `release_manifest.sh` once all preparation work are done, and new DAQ packages are available in cvmfs.


3. Build and package DAQ packages
    * checkout the desired version of `daq-buildtools`, and set up a working directory using the release configs created by the previous step;
    * checkout all DAQ packages into `sourcecode` and build them with `dbt-build.sh`;
    * run [upsify-daq-packages script](https://github.com/DUNE-DAQ/daq-release/blob/develop/scripts/upsify-daq-pkgs.py) to make tarballs of the DAQ packages ([instructions](https://github.com/DUNE-DAQ/daq-release/blob/develop/doc/upsify_daq_packages.md);
    * publish the DAQ packages into cvmfs ([instructions](https://github.com/DUNE-DAQ/daq-release/blob/develop/doc/publish_to_cvmfs.md)).


4. Modify `dbt-setting.sh` to use the newly published DAQ packages in cvmfs, create a new working directory and run some integration tests;


6. Modify `release_manifest.sh` with new list of DAQ packages, externals etc, and the anticipated new tags of `daq-release`, and `dbt-settings.sh` with the anticipated new release directory in cvmfs;


7. Merge the release preparation branch of `daq-release`, and tag a new version;


8. Use the [release creating script](https://github.com/DUNE-DAQ/daq-release/blob/develop/scripts/create-release-dir.sh) to create a tarball of the new release, and deploy it on cvmfs;


9. Up till this point, the new release should be available in cvmfs, give it a test, prepare new documentation for developers and make the announcement for beta testing the new release;


10. Wait 24 hours, for any possible hotfixes, before making the release tag with the [release tagging script](https://github.com/DUNE-DAQ/daq-release/blob/develop/scripts/create-release-tag.sh).
