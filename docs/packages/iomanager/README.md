# iomanager

A simplified API for passing messages between DAQModules

## API Description

### IOManager


* Main point-of-contact for Unified API

* Methods to retrieve Sender/Receiver instances using ConnectionRefs or uid

* Configures Queues and NetworkManager automatically in `configure`

### ConnectionId & ConnectionRef


* ConnectionId defines a connection, with required initialization

  * uid Field uniquely identifies the connection

  * partition Field identifies the partition that the connection is associated with

  * uri Field is used by lower-level code to configure the connection

    * Scheme `queue://` should be used for queues, with the queue type and size, e.g. `queue://StdDeQueue:10` creating a StdDeQueue of size 10

    * For network connections, standard ZMQ URI should be used, e.g. `tcp://localhost:1234` (name translation is provided by IPM)

* ConnectionRef is a user-facing reference to a connection

### Receiver


* Receiver is base type without template (for use in IOManager::m_receivers)

* ReceiverConcept introduces template and serves as class given by IOManager::get_receiver

* QueueReceiverModel and NetworkReceiverModel implement receives and callback loop for queues and network

  * NetworkReceiverModel::read_network determines if type is serializable using template metaprogramming

### Sender


* Similar design as for Receivers

* QueueSenderModel and NetworkSenderModel implement sends for queues and network

* NetworkReceiverModel::write_network determines if type is serializable using template metaprogramming

### API Diagram

![Class Diagrams](https://github.com/DUNE-DAQ/iomanager/raw/develop/docs/IOManager.png)

## Examples

### Send

```CPP
  // Int sender
  dunedaq::iomanager::ConnectionRef cref;
  cref.uid = "bar";
  cref.topics = {};

  int msg = 5;
  std::chrono::milliseconds timeout(100);
  auto isender = IOManager::get()->get_sender<int>(cref);
  isender->send(msg, timeout);
  isender->send(msg, timeout);

  // One line send
  IOManager::get()->get_sender<int>(cref)->send(msg, timeout);

```

### Receive (direct)

```CPP
// String receiver
  dunedaq::iomanager::ConnectionRef cref3;
  cref3.uid = "dsa";
  cref3.topics = {};

  auto receiver = IOManager::get()->get_receiver<std::string>(cref3);
  std::string got;
  try {
    got = receiver->receive(timeout);
  } catch (dunedaq::appfwk::QueueTimeoutExpired&) {
    // This is expected
  }

```

### Receive (callback)

```CPP
  // Callback receiver
  dunedaq::iomanager::ConnectionRef cref4;
  cref4.uid = "zyx";
  cref4.topics = {};

  // CB function
  std::function<void(std::string)> str_receiver_cb = [&](std::string data) {
    std::cout << "Str receiver callback called with data: " << data << '\n';
  };

  auto cbrec = IOManager::get()->get_receiver<std::string>(cref4);
  cbrec->add_callback(str_receiver_cb);
  try {
    got = cbrec->receive(timeout);
  } catch (dunedaq::iomanager::ReceiveCallbackConflict&) {
    // This is expected
  }
  IOManager::get()->remove_callback(cref4);

```

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed May 4 10:55:30 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/iomanager/issues](https://github.com/DUNE-DAQ/iomanager/issues)_
</font>
