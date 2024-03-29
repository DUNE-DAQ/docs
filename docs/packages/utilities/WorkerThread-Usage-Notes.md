# About utilities::WorkerThread

WorkerThread defines a std::thread which runs the do_work() function as well as methods to start and stop that thread.
It is intended to help reduce code duplication for the common task of starting and stopping threads.

## Instantiation

WorkerThread's constructor takes a `std::function<void(std::atomic<bool>&) do_work` parameter. This corresponds to the function that should be run in the thread when it is started. The single parameter is used to indicate that the thread should conclude its work and exit when false. (i.e. threads are expected to have a `while(running_flag)` loop in their `void do_work(std::atomic<bool>& running_flag)` method.)

## Starting the worker thread

WorkerThread defines a `start_working_thread` method which should be called to start the working thread. This method takes a single argument which is the desired pthread name for the working thread. This name is limited to 15 characters, over-long names will result in the new thread sharing the name of the calling process. The set name will not be immediately available within the `do_work` method and should not be relied upon.

## Stopping the worker thread

WorkerThread defines a `stop_working_thread` method which will set the atomic boolean running flag to false, indicating that the worker thread should exit. It will then attempt to join the working thread. The contract with the do_work method is thus that when the running flag is set to false, the method should conclude its work in a timely fashion.

## Other Notes

Users of WorkerThread may call the `thread_running()` method to determine if `start_working_thread` has been called. Since the method run by WorkerThread is in the caller's scope, the working method has access to all state variables in that scope. Beware that most STL container types are not intrinsically thread-safe, and care should be used when accessing shared data.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Tue Jan 18 11:08:02 2022 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/utilities/issues](https://github.com/DUNE-DAQ/utilities/issues)_
</font>
