# Interacting with the Configuration Database

## Uploading a config
To use configuration files with a _nanorc_ instance run on Kubernetes, the config first needs to be uploaded to the MongoDB running in the cluster.
To do this, simply run `upload-conf <the_conf_dir/> <name-for-the-conf>`.

_nanorc_ should then be started with `nanorc --pm k8s://np04-srv-015:31000 db://name-for-the-conf partition-name`

Keep in mind that the config directory can contain underscores, but the name it will be given in the database cannot (hyphens are fine).

## Viewing configurations
To inspect the contents of the database, run `daqconf_viewer` after setting up the software environment. This will open a graphical UI in the terminal.
![Config Viewer](ConfViewerScreenshot.png)
A list of all configuration names is shown on the left. 
Clicking one of them will generate a list of buttons at the top, corresponding to the saved versions of the config.
Press one of those buttons to bring up the config file in the display box. By clicking the arrows, the contents of each sub-schema can be expanded.

Pressing the D key after picking a config will take you to a very similar screen, albeit with green lines instead of red. 
If a second config is selected using the previously defined process, then a "diff" of the two will be generated, showing all the 
differences between the two in a format similar to how commits are displayed on github.
Finally, once you are done press q to quit (or use ctrl+c).


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Jonathan Hancock_

_Date: Fri Jun 30 14:04:51 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
