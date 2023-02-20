# IOManager Test Applications

## config_client_test

This test application is a simple test of the ConfigClient functionality, and tests the amount of time needed to publish, lookup, and retract a given number of connections.

## iomanager_stress_test

This test application tries to emulate the send/recv part of a large DAQ session. It does this by creating a number of Sender and Receiver pair applications, each with a number of connections between them. Configuration options include the number of app pairs to start, the number of connections for each app pair, the number of messages that they will send to one another, and the size of each message.

A "Control" channel is used by the Receiver app to notify the Sender that it is ready to start receiving messages and that it has completed reception of all expected messages. These control messages allow the separate proceeses to remain synchonized.

The Connectivity Service will have N_apps * N_connections + N_apps connections registered, which means that systems consisting of O(1000) connections can be tested with this app. The Connectivity Service can also be run on a separate host, and multiple instances of the iomanager_stress_test executable can be spread to other hosts to increase the synthetic load.

## iomanager_stress_test_pubsub

This test application is largely similar to the iomanager_stress_test, but with several modifications to reflect the publish/subscribe pattern used, for example, by TPSets. It starts a number of Publisher and Subscriber apps, each running a number of "groups" of connections. Each connection has a dedicated subscriber endpoint, and there is also a subscriber endpoint listening to all connections in each group.

Here, the Publishers start sending without waiting for any control messages, and continue to send until they receive a "QuotaReached" message for the appropriate connection from the Subscriber app. This reflects the fact that ZeroMQ allows for messages to be dropped under certain conditions in pub/sub mode.

The Connectivity Service will have N_apps + N_apps * N_groups * N_connections connections registered for this test. Note that with three multiplicative factors, very large systems can be configured if the user is not careful!

## queue_IO_check

This test application checks the DUNE-DAQ queues for thread-safe behavior and ensures that the Queue API works correctly.

## queues_vs_threads

These test applications show the effect on timing of using multiple threads on reception from queues while using Folly Queues by themselves, by using timeout exceptions, and by using IOManager.

## reconnection_test

This test application starts a "ring" of applications that pass messages. Each application is assigned an ID number, and when it receives a message from ID - 1, it sends it on to ID + 1. The apps are aware of the number of apps in the system, so the last app sends to ID 0, which then starts the next round of messages.

The executable takes an ID as an argument, so if one of the apps in the ring is killed, it can be replaced using the command-line, and the user can observe how the ring recovers and continues to pass messages as before.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Mon Feb 20 13:42:44 2023 -0600_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/iomanager/issues](https://github.com/DUNE-DAQ/iomanager/issues)_
</font>
