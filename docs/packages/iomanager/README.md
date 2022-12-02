# iomanager

A simplified API for passing messages between DAQModules

## API Description

### IOManager


* Main point-of-contact for Unified API

* Methods to retrieve `Sender`/`Receiver` instances using `ConnectionRef`s or `uid` (defined below)

* Configures `Queue`s and `NetworkManager` automatically in `configure`

### Using IOManager from DAQModule code


* `dunedaq::get_iomanager()` will return a pointer to the IOManager singleton

* `IOManager::get_sender<DataType>(std::string uid)` and `IOManager::get_receiver<DataType>(std::string uid)` should be used to get Sender and Receiver objects connected to the appropriate connections. Note that `ConnectionId` objects are not required, as they will be constructed from the provided DataType and uid arguments.

* Subscribers interested in multiple connections for a single DataType should use a Regular Expression to match the desired connections; this can be anywhere from a full wildcard (`".*"`) to a specific connection UID, depending on the desired scope of the subscription. Topics are now automatically assigned by IOManager as the string representation of DataType.

* The `topic` argument has been removed from `SenderConcept<T>::send`

* `appfwk` will give DAQModules a list of `appfwk::app::ConnectionReference` objects, which associate a "name" to connection UIDs. Methods in `DAQModuleHelper.hpp` take DAQModule configuration objects and extract specific UIDs for given names.
```C++
  auto mandatory_connections =
    appfwk::connection_index(init_data, { "token_connection", "td_connection", "busy_connection" });

  m_token_connection = mandatory_connections["token_connection"];
  m_td_connection = mandatory_connections["td_connection"];
  auto busy_connection = mandatory_connections["busy_connection"];

  m_busy_sender = iom->get_sender<dfmessages::TriggerInhibit>(busy_connection);
```

* Upon agreement from both endpoints, a connection can use a generated UID string (e.g. from SourceID::to_string()). 

### Other Notes for Framework Developers


* The `serialization` library provides a new macro `DUNE_DAQ_TYPESTRING(Type, string)` which is included in the standard `DUNE_DAQ_SERIALIZABLE` and `DUNE_DAQ_SERIALIZE_NON_INTRUSIVE` macros (called from the `dunedaq` namespace only). These macros define the function `datatype_to_string<T>` which is used by IOManager to translate a datatype to the appropriate string. This template function **must** be visible in every compilation unit sending or receiving a given type!

  * If it is not available, an error message will be produced at runtime that IOManager was unable to find connection "uid" of type Unknown

* In `daqconf`, all connections and queues **must** have a declared data type that matches a call to `DUNE_DAQ_TYPESTRING`. `add_endpoint` and `connect_modules` have changed their API to accomodate this.

### ConnectionId, Connection, & Queue


* `ConnectionId` uniquely identifies a network connection or queue

  * `uid`: String identifier for connection

  * `data_type`: String representation of data type

* `Connection` defines a network connection, with required initialization

  * `id`: `ConnectionId`

  * `connection_type`: Describes what kind of connection (kSendReceive, kPubSub)

  * `uri`: Field is used by lower-level code to configure the connection

    * Standard ZMQ URI should be used, e.g. `tcp://localhost:1234` (name translation is provided by IPM)

* `QueueConfig` represents an app-internal queue

  *  `id`: `ConectionId`

  *  `queue_type`: Type of the queue implementation (e.g. kStdDeQueue, kFollySPSCQueue, kFollyMPMCQueue)

  *  `capacity`: Capacity of the queue

### Receiver


* `Receiver` is base type without template (for use in `IOManager::m_receiver`s)

* `ReceiverConcept` introduces template and serves as class given by `IOManager::get_receiver`

* `QueueReceiverModel` and `NetworkReceiverModel` implement receives and callback loop for queues and network

  * `NetworkReceiverModel::read_network` determines if type is serializable using template metaprogramming

### Sender


* Similar design as for `Receiver`s

* `QueueSenderModel` and `NetworkSenderModel` implement sends for queues and network

* `NetworkReceiverModel::write_network` determines if type is serializable using template metaprogramming

### API Diagram

![Class Diagrams](https://github.com/DUNE-DAQ/iomanager/raw/develop/docs/IOManager.png)

## Examples

### Send

```CPP
  // Int sender
  std::string uid = "bar";
  
  int msg = 5;
  std::chrono::milliseconds timeout(100);
  auto isender = IOManager::get()->get_sender<int>(uid);
  isender->send(msg, timeout);
  isender->send(msg, timeout);

  // One line send
  IOManager::get()->get_sender<int>(uid)->send(msg, timeout);
  
  // Send when timeouts may occur
  bool sent = isender->try_send(msg, timeout);

```

### Receive (direct)

```CPP
// String receiver
  std::string uid = "bar";

  auto receiver = IOManager::get()->get_receiver<std::string>(uid);
  std::string got;
  try {
    got = receiver->receive(timeout);
  } catch (dunedaq::appfwk::QueueTimeoutExpired&) {
    // Deal with exception
  }
  
  // Alternate API for when timeouts may be allowed
  std::optional<std::string> ret = receiver->try_receive(timeout);
  if(ret) TLOG() << "Received " << *ret;

```

### Receive (callback)

```CPP
  // Callback receiver
  std::string uid = "zyx";

  // CB function
  std::function<void(std::string)> str_receiver_cb = [&](std::string data) {
    std::cout << "Str receiver callback called with data: " << data << '\n';
  };

  auto cbrec = IOManager::get()->get_receiver<std::string>(uid);
  cbrec->add_callback(str_receiver_cb);
  try {
    got = cbrec->receive(timeout);
  } catch (dunedaq::iomanager::ReceiveCallbackConflict&) {
    // This is expected
  }
  IOManager::get()->remove_callback(uid);

```
## When to use "try_" methods

The standard `send()` and `receive()` methods will throw an ERS exception if they time out. This is ideal for cases where timeouts are an exceptional condition (this applies to most, if not all send calls, for example). In cases where the timeout condition can be safely ignored (such as the callback-driving methods which are retrying the receive in a tight loop), the `try_send` and `try_receive` methods may be used. Note that these methods are **not** `noexcept`, any non-timeout issues will result in an ERS exception.

## Updating existing code to use IOManager

Please see [this page](Updating.md) for information about updating your code to use IOManager.

## APIs used by IOManager

The API used for queues is documented [here](Queue.md). Network connections use [IPM](https://dune-daq-sw.readthedocs.io/en/latest/packages/ipm/) and [NetworkManager](NetworkManager.md)


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Oct 26 09:56:58 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/iomanager/issues](https://github.com/DUNE-DAQ/iomanager/issues)_
</font>
