# Updating to the v3.3.0 IOManager API

IOManager made several changes which affect configuration generation for v3.3.0. The biggest of these from a `daqconf` perspective is that data type strings **must** be present in the configuration of connections for them to be processed correctly.

## Updating Application Configuration Generation Sripts (*_gen.py)

The `connect_modules`, `add_endpoint` methods and the `Queue` constructor from `daqconf.core` now take an additional `data_type` parameter, which should match the data types declared in the code. In most cases, this is the same as the C++ class name (e.g. "TPSet", "Fragment"), but a few have been declared specifically (e.g. "WIBFrame" instead of "WIB_SUPERCHUNK_STRUCT").

When updating, it is useful to generate configurations and check the "queues" and "connections" lists in the generated *_init.json files for correct names and data types. Running a configuration with incorrect data types will produce error messages from IOManager which should include enough information to track down the connection causing the error. (Code issues such as undeclared data types can also cause IOManager issues, though that commonly results in one specific message: "Connection named "uid" of type Unknown not found".)

## Updating Configuration Generation Scripts (e.g. listrev_gen, daqconf_multiru_gen)

The main change for configuration generation scripts is the addition of the "boot.use_connectivity_service" parameter to the main daqconf schema, which should be passed to make_app_command_data to enable/disable features of the configuration generation logic related to the ConnectivityService.

If use_connectivity_service is True, `daqconf.core.conf_utils.make_system_connections` will only output connection data for "bind"-type network connections and queues, and allow the ConnectivityService to handle "connect"-type network connections. Otherwise, all connection UIDs and URIs are output to the generated JSON files.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Oct 26 09:53:00 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/daqconf/issues](https://github.com/DUNE-DAQ/daqconf/issues)_
</font>
