# restcmd README
## Running the DAQ application
    daq_application --commandFacility rest://localhost:12345

## Sending a command

    send-restcmd.py --file ../test/test-init.json

## Sending a command sequence
The script checks if there are multiple command objects to send. (File contains a JSON array of objects.)
One can also specify a wait time between sending commands.

    send-restcmd.py --file ../test/fdpc-commands.json --wait 3

## Sending command in interactive mode
There is also an interactive mode. This requires typing the next command's ID from the set of commands that are available in the file:

    send-restcmd.py --file ../test/fdpc-commands.json --interactive

## Receiving command return

    recv-restcmd.py

starts a Flask server exposing a POST `/response` route on a configurable port (default 12333).

## Sending and receiving command replies

    send-recv-restcmd.py

The best of both scripts with a fancy "command reply queue".

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Enrico Gamberini_

_Date: Tue Mar 2 10:44:59 2021 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/restcmd/issues](https://github.com/DUNE-DAQ/restcmd/issues)_
</font>
