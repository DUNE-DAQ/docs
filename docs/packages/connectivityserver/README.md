# connectivityserver
This service provides a very simple flask based server to serve connection information to DAQ applications.



## Running the server locally from the command line
The server is intended to be run under the Gunicorn web server.
```bash
gunicorn -b 0.0.0.0:5000 --workers=1 --worker-class=gthread --threads=2 \
       --timeout 5000000000 connectivityserver.connectionflask:app
```
Some debug information will be printed by the connection-flask if the environment variable `CONNECTION_FLASK_DEBUG` is set to a number greater than 0. Currently 1 will print timing information for the publish/lookup calls. 2 will give information about what was published/looked up and 3 is even more verbose printing the actual JSON of the requests.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: PawelPlesniak_

_Date: Tue Nov 10 19:31:26 2026 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/connectivityserver/issues](https://github.com/DUNE-DAQ/connectivityserver/issues)_
</font>
