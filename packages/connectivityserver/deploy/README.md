# connectivityserver

 This service provides a very simple flask based
server to serve connection information to DAQ applications.

## Installation

To build the docker image of develop just do
```bash
docker buildx build --tag ghcr.io/dune-daq/connectivityserver:latest .
```
Or, if you want to specify a tag
```bash
docker buildx build --tag ghcr.io/dune-daq/connectivityserver:v1.3.0 --build-arg VERSION=v1.3.0 .
```

 Apply the kubernetes manifest from connectivityserver.yaml. This
 should start a service called connectionservice in the namespace
 connections.

```
kubectl apply -f connectivityserver.yaml
```

To test the basic operation of the server, you can connect to  pod in the k8s cluster and try getting the root document.

```
> kubectl exec myPod -i -t -- bash
[root@myPod /]# curl http://connectionservice.connections:5000
<h1>Dump of configuration dictionary</h1><h2>Active partitions</h2><p>None</p><hr><h2>Server statistics</h2><p>Since 2023-03-16 09:15:06.571492</p><p>0 calls to publish in total time 0:00:00 (average 0 &micro;s per call)</p><p>0 calls to lookup in total time 0:00:00 (average 0 &micro;s per call)</p><p>Maximum number of partitions active = 0</p>
[root@myPod /]#
```

## Connectivityserver operation
Please refer to the documentaion in the
connectivityserver package [https://github.com/DUNE-DAQ/connectivityserver].


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Gordon Crone_

_Date: Thu Oct 16 16:54:02 2025 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/connectivityserver/issues](https://github.com/DUNE-DAQ/connectivityserver/issues)_
</font>
