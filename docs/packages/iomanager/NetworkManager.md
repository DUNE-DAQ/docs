# NetworkManager

## Introduction

NetworkManager is used by IOManager to configure and manage network connections (similar to how QueueRegistry configures and manages Queues).

### NetworkManager

Manages active connections within the application, as well as communicating the the ConfigClient to talk to the ConnectivityService

### ConfigClient

Wrapper around the HTTP API for the ConnectivityService to perform network connection registration and lookup

### NetworkReceiverModel

Represents the receive end of a network connection, implementation of ReceiverConcept and exposed to DAQModules via `IOManager::get_receiver<T>`

### NetworkSenderModel

Represents the send end of a network connection, implementation of SenderConcept and exposed to DAQModules via `IOManager::get_sender<T>`

## API Description

![Class Diagrams](https://github.com/DUNE-DAQ/iomanager/raw/develop/docs/NetworkManager.png)

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Wed Oct 19 13:49:32 2022 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/iomanager/issues](https://github.com/DUNE-DAQ/iomanager/issues)_
</font>
