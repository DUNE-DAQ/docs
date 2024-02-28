# SNBmodules
Welcome to the snbmodules wiki!

This library uses external libraries such as Bittorent or Rclone that need to be installed.



1. Clone this repo into the sourcecode/ directory and add the library name to the dbt-build-order.cmake



2. Source the environment and install external libraries



3. Add to env.sh file the export of the libraries and source again



4. Build and Configure the test environment



5. Start new transfers and enjoy~

# TODO

- Add listening folder list for clients
- Auto start RClone HTTP server on source client (Uploader)
    - For now, we can start the server with rclone serve, see [Install local server section](#run-local-server)

# Wiki

Please follow the wiki pages for detailed instructions and information about:
- [Installation](https://github.com/DUNE-DAQ/snbmodules/wiki/Installation)
- [Configuration](https://github.com/DUNE-DAQ/snbmodules/wiki/Configuration)
- [Transfers](https://github.com/DUNE-DAQ/snbmodules/wiki/Transfers)
- [Technical Documentation](https://github.com/DUNE-DAQ/snbmodules/wiki/Technical-Documentation)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Léo Joly_

_Date: Tue Sep 26 11:28:23 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
