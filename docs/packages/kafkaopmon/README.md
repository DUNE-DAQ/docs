# `kafkaopmon` - Kafka plugin for Operational Monitoring
Kafkaopmon converts a JSON object into an kafka message, ready to be used as a time series

## Building and running :
The library's constructor takes an URI argument. The URI's syntax is the database : Application name: `kafka://<host>:<port>/<topic>`. 

The library should be used calling the library's "publish" function with as argument a `nlohmann::json` object. More details about the implementation are available in the "Technical information" chapter.

The library output is the return statement from the CPR message and, if successfull, the insertion of the JSON content to the TSDB.

### URI example :
the kafkaopmon URI presents as such: kafka://188.185.122.48:9092
Translating in the full, following URI eyample:

```
daq_application -c rest://localhost:12345 --name asd -i kafka://188.185.122.48:9092/opmon 
```

### Step-by-step :


1. In a build environment clone the latest kafkaopmon tag from DUNE-DAQ


2. Verify your environment includes the opmonlib module


3. Compile your environment


4. In a runtime environment, run the call URI

## consumers
Consumers for this stream can be found in [DUNEDAQ/microservices](https://github.com/DUNE-DAQ/microservices)

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Marco Roda_

_Date: Tue Jul 12 18:22:33 2022 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/kafkaopmon/issues](https://github.com/DUNE-DAQ/kafkaopmon/issues)_
</font>
