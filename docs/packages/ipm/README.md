# ipm
Inter-Process Messaging

The IPM library provides the low-level library for for sending messages between DUNE DAQ processes. IPM deals with messages consisting of arrays of bytes: higher-level concepts such as object serialization/deserialization will be handled by other libraries and processes building on IPM.

IPM provides two communication patterns:



1. `Sender`/`Receiver`, a pattern in which one sender talks to one receiver


2. `Publisher`/`Subscriber`, a pattern in which one sender talks to zero or more receivers. Each message goes to all subscribers

Users should interact with IPM via the interfaces `dunedaq::ipm::Sender`, `dunedaq::ipm::Receiver` and `dunedaq::ipm::Subscriber`, which are created using the factory functions `dunedaq::ipm::makeIPM(Sender|Receiver|Subscriber)`, which each take a string argument giving the implementation type. The currently-available implementation types all use ZeroMQ, and are:


* `ZmqSender` implementing `dunedaq::ipm::Sender` in the sender/receiver pattern

* `ZmqReceiver` implementing `dunedaq::ipm::Receiver`

* `ZmqPublisher` implementing `dunedaq::ipm::Sender` in the publisher/subscriber pattern

* `ZmqSubscriber` implementing `dunedaq::ipm::Subscriber`

Basic example of the sender/receiver pattern:

```c++
// Sender side
std::shared_ptr<dunedaq::ipm::Sender> sender=dunedaq::ipm::makeIPMSender("ZmqSender");
sender->connect_for_sends({ {"connection_string", "tcp://127.0.0.1:12345"} });
void* message= ... ;
// Last arg is send timeout
sender->send(message, message_size, std::chrono::milliseconds(10));

// Receiver side
std::shared_ptr<dunedaq::ipm::Receiver> receiver=dunedaq::ipm::makeIPMReceiver("ZmqReceiver");
receiver->connect_for_receives({ {"connection_string", "tcp://127.0.0.1:12345"} });
// Arg is receive timeout
Receiver::Response response=receiver->receive(std::chrono::milliseconds(10));
// ... do something with response.data or response.metadata
```

Basic example of the publisher/subscriber pattern:

```c++
// Publisher side
std::shared_ptr<dunedaq::ipm::Sender> publisher=dunedaq::ipm::makeIPMSender("ZmqPublisher");
publisher->connect_for_sends({ {"connection_string", "tcp://127.0.0.1:12345"} });
void* message= ... ;
// Third arg is send timeout; last arg is topic for subscribers to subscribe to
publisher->send(message, message_size, std::chrono::milliseconds(10), "topic");

// Subscriber side
std::shared_ptr<dunedaq::ipm::Subscriber> subscriber=dunedaq::ipm::makeIPMReceiver("ZmqSubscriber");
subscriber->connect_for_receives({ {"connection_string", "tcp://127.0.0.1:12345"} });
subscriber->subscribe("topic");
// Arg is receive timeout
Receiver::Response response=subscriber->receive(std::chrono::milliseconds(10));
// ... do something with response.data or response.metadata
```

More complete examples can be found in the `test/plugins` directory.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: John Freeman_

_Date: Thu Apr 22 14:21:23 2021 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/ipm/issues](https://github.com/DUNE-DAQ/ipm/issues)_
</font>
