# connectivityserver

 This service provides a very simple flask based
server to serve connection information to DAQ applications.


## REST interface

  The server reponds to the following uris

### /publish
 Allows publication of connection information. The content of the
 request should be JSON encoded. For example, the following json file
 can be published using curl.

```
> cat publish.json
{
 "connections":[
  {
   "connection_type":0,
   "data_type":"TPSet",
   "uid":"DRO-000-tp_to_trigger",
   "uri":"tcp://192.168.1.100:1234"
  },
  {
   "connection_type":0,
   "data_type":"TPSet",
   "uid":"DRO-001-tp_to_trigger",
   "uri":"tcp://192.168.1.100:1235"
  }
 ],
 "partition":"ccTest"
}

> curl -d @publish.json -H "content-type: application/json" \
    http://connection-flask.connections:5000/publish
```

### /getconnection/<partition> 
This uri returns a list of connections matching the 'uid_regex' and
'data_type' specified in the JSON encoded request.

```
curl -d '{"uid_regex":"DRO.*","data_type":"TPSet"}' \
    -H "content-type: application/json" \
     http://connection-flask.connections:5000/getconnection/ccTest
[{"uid": "DRO-000-tp_to_trigger", "uri": "tcp://192.168.1.100:1234", "connection_type": 0, "data_type": "TPSet"}, {"uid": "DRO-001-tp_to_trigger", "uri": "tcp://192.168.1.100:1235", "connection_type": 0, "data_type": "TPSet"}]
```


### /retract
This uri should be used to remove published connections. The request should be JSON encoded with the keys "partition" and "connections" with the latter being an array of "connection_id" and "data_type" values.


### /retract-partition
This uri should be used to remove all published connections from the
given partition. The request should be JSON encoded with one field "partition" naming the partition to be retracted.

## Running the server locally from the command line
 The server is intended to be run under the Gunicorn web server.
 
 ```
 gunicorn -b 0.0.0.0:5000 --workers=1 --worker-class=gthread --threads=2 \
        --timeout 5000000000 connectivityserver.connectionflask:app
 ```

Some debug information will be printed by the connection-flask if the
environment variable 'CONNECTION_FLASK_DEBUG' is set to a number
greater than 0. Currently 1 will print timing information for the
publish/lookup calls. 2 will give information about what was
published/looked up and 3 is even more verbose printing the actual
JSON of the requests.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Gordon Crone_

_Date: Thu Oct 16 16:54:02 2025 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/connectivityserver/issues](https://github.com/DUNE-DAQ/connectivityserver/issues)_
</font>
