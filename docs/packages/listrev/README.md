# listrev

The listrev package allows to excercise the basic functioning of DAQ applications, through three simple DAQ Modules that operate on lists of numbers.

In order to run it, setup the runtime environment for the DAQ version you are using.

Then in `drunc-unified-shell` you can boot the example session included in the release with the command `boot config/lrSession.data.xml lr-session`

If you want to modify the example session, you can copy it to your work directory and edit with `dbe_main -f lrSession.data.xml` or your favourite text editor.
   ```
   cp $DUNE_DAQ_RELEASE_SOURCE/listrev/config/lrSession.data.xml .
   ```


## Evaluating the listrev Run


  * `grep Exiting log_*lr-session_listrev*` will show the reported statistics.

  * The example is targeted at 100 Hz, so the expected number of messages seen by ReversedListValidator should be at least 100 times the run duration.

  * There should be three lists in each message (from the three generators), so it should report 300 times the run duration for the number of lists.

  * Messages are round-robined to the two reversers, so each should see 50run_duration messages and 150run_duration lists. They should have approximately equal values for the reported counters.

  * Generators should generate 100*run_duration lists and send all (or almost all) of them.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Gordon Crone_

_Date: Thu Aug 1 11:54:59 2024 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/listrev/issues](https://github.com/DUNE-DAQ/listrev/issues)_
</font>
