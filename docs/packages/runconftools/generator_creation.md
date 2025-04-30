# How to create a new generator

A generator takes the local base repository and it changes the OKS database to obtain the desired configuration. 
The scripts in this package will then commit the changes and create the configuration on the remote operation repository. 

The generators are called automatically from the scripts of this package to create the corresponding configurations. 
So, creating a configuration is equivalent to write the corresponding generator. 

## Generator structure
Generators are stored in the base repo, as they are specific for the base that they have to work upon in order to create the necessary configuration. 
Specifically, they are stored in the folder `functions/generators` directory in the subdirectory specific for the apparatus relevant for the generator. 

Generators are python modules and are expected to be named with with `<configuration_name>.py`. 
As the generators might be imported by other generators, their names cannot contain `-`. 

Generators will have to contains a generate function with signature
```python
def generate( path:str ) -> bool :
```
Where the incoming path is mandatory and is expected to point to the location of the base repository on which the generator will act.
This will be handled by the runconftools scripts. 

The generate function must return `True` once the generation is successfully completed. 
Otherwise, it should return `False` or raise an exception. 

In order to use the configutions in the base repository, some environmental variables need to be set. 
This is usually done with the script `setup_db_path.sh` contained in the base. 
While writing a generator, one should assume that those environmental variables are correctly setup and should not try to set them from the scripts. 

### Good practices

As the generator is a python script, one could do everything. 
Yet it is recommended that the OKS database are managed through the OKS, conffwk or daqconf python interfaces/scripts which guarantess type safety. 
One should not change the files using python `open` or other low level file editing tools. 

It is also recommended that we limit the changes to the objects to just changing the references rather than the attributes of the objects. 
Although in some cases that might be unavoidable. 

## Generator testing

Generators should be tested before committing and before starting updating the operation repository. 
In order to test the generator, it is recommended that that the generator contains the block
```python
if __name__ == '__main__':
    generate(sys.argv[1])
```

So that the generator can be tested by simply executing
```bash
python my_generator.py /path/to/base 
```
Or something very similar in spirit. 

While developing, personal experience suggested that is quite useful to develop the generator by initially saving the file outside the local base git repository. 
In this way the chages made to the base by executing the generator can simply be reverted with a 
```bash
(cd /path/to/base; git restore)
```
Once the development is done and the result of the generator is tested, ideally with a succesful run, the file can be added to the base git repository, committed, pushed to the remote base and the operation repository can be updated. 

## Validators

Similarly to the generate function, the same file can contain - but it's not mandatory - a 
```Python
def validate( path:str ) -> bool :
```
function. 
This is used to perform specific operations that validate the configuration. 
As with the `generate` function, this is called by the runconftools scripts. 

The function must return `True` in case the configuration is found to be correct by the function, or `False` otherwise. 

## Common operations
It is possible to call other generators or common functions. 
Common functions should be store in the base repository, in the directory `functions/common`. 
As the function directory is added to the `PYTHONPATH`, one can invoke those functions just by importing. 
For example:
```python
import common.trigger
```
Same for other generators, that can be imported using
```python
import generators.np02.monitoring_no_tpg
```
The import of other generators or commong functions has to be done from withing the module functions or the import will fail when calling the generator in a testing phase. 
The structure of the process name validator block to be used when calling other generator or common function will look like 
```python
if __name__ == '__main__':
    sys.path.append(sys.argv[1] + "/functions")
    generate(sys.argv[1])
    validate(sys.argv[1])
```

## Example

```python
import sys

import conffwk
import confmodel

import daqconf.enable as enable

def generate( path:str ) -> bool :

    import common.np02.config_base as base
    entry = base.get_entry_file(path)

    session=base.get_session_name()

    # enable all the det streams for the daphne
    enable.enable(entry, False, ["np02-pds107-s00-sid50"], session)

    db = base.get_database(path)

    # change the daphne configuration
    daphne_app = db.get_dal("DaphneApplication", "daphne-app")
    daphne_conf = db.get_dal("DaphneConf", "full_mode_bias_off")
    daphne_app.configuration = daphne_conf
    db.update_dal(daphne_app)
    
    
    # change the descriptor of the queue rule in the flx readout app
    queue_rule = db.get_dal("QueueConnectionRule", "daphne-raw-data-rule")
    queue_descriptor = db.get_dal("QueueDescriptor", "daphne-fullstream-raw-input")
    queue_rule.descriptor=queue_descriptor
    db.update_dal(queue_rule)


    # change the link handler in the RU
    readout_app = db.get_dal("ReadoutApplication", "runp02srv030flx4")
    data_handler = db.get_dal("DataHandlerConf", "pds-handler-numa0-fullstream")
    readout_app.link_handler = data_handler
    db.update_dal(readout_app)

    # Change the felix controller
    flx_controller_app = db.get_dal("DaqApplication", "pds-felix")
    full_stream_controller_module = db.get_dal("FelixCardControllerModule", "np02-pds-controller-fullstream")
    flx_controller_app.modules=[full_stream_controller_module]
    db.update_dal(flx_controller_app)

    # change the protocol to full
    flx_senders = db.get_dals("FelixDataSender")
    for s in flx_senders :
        s.protocol = "full"
        db.update_dal(s)
    
    db.commit()
    return True


if __name__ == '__main__':
    sys.path.append(sys.argv[1] + "/functions")
    generate(sys.argv[1])
```

This is an example of a generator that uses both `daqconf` and `conffwk` scripts. 
As you can see, most of the time, it is just changing the reference between the objects. 
The only exception is the `FelixDataSender` class that it's part of the topology description of the connections. 
Therefore its objects are not duplicated. 


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: MRiganSUSX_

_Date: Tue Apr 8 12:49:40 2025 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/runconftools/issues](https://github.com/DUNE-DAQ/runconftools/issues)_
</font>
