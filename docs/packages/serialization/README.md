# DUNE DAQ C++ object serialization utilities

This repository contains utilities for serializing/deserializing C++ objects for DUNE DAQ. Serialization allows objects to be sent across the network or persisted to disk.

## Quick start

An appropriately-defined C++ type (see below) can be serialized/deserialized as follows:

```cpp
 MyClass m;
 m.some_member=3;
 // ... set other parts of m...
 dunedaq::serialization::SerializationType stype=dunedaq::serialization::kMsgPack; // or kJSON, which is human-readable but slower
 std::vector<uint8_t> bytes=dunedaq::serialization::serialize(m, stype);
 
 // ...elsewhere, after receiving the serialized object:
 MyClass m_recv=dunedaq::serialization::deserialize<MyClass>(bytes);
```

## Making types serializable

### With [`moo`](https://github.com/brettviren/moo)

If your type is specified via a `moo` schema, you just need to `moo render` your schema with the `onljs.hpp.j2` template (for json serialization) and with `omsgp.hpp.j2` (for MsgPack serialization; requires `moo` > 0.5.0). Then you will need to `#include` both of the generated headers wherever you serialize/deserialize objects of your type.

### Without [`moo`](https://github.com/brettviren/moo)

If your class is not specified via a `moo` schema, it can be made serializable by adding convertor functions for `msgpack` and, optionally, `nlohmann::json`. If convertor functions are only provided for `msgpack` and not for `nlohmann::json`, json serialization is done by the serialization library: the object is converted to msgpack format and from there to json (and similarly to deserialize).

The easiest way to make your class (de)serializable is with the `DUNE_DAQ_SERIALIZE()` convenience macro provided in [`Serialization.hpp`](./include/serialization/Serialization.hpp):

```cpp
// A type that's made serializable "intrusively", ie, by changing the type itself
namespace ns {
struct MyTypeIntrusive
{
  int some_int;
  std::string some_string;
  std::vector<double> some_vector;

  DUNE_DAQ_SERIALIZE(MyTypeIntrusive, some_int, some_string, some_vector);
};
} // namespace ns
```

You may not be able to change the type itself, either because you
don't have access to it, or because it lives in a package that cannot
depend on the `serialization` package. In this case, you can use the
`DUNE_DAQ_SERIALIZE_NON_INTRUSIVE()` macro instead. In the _global_
namespace, call `DUNE_DAQ_SERIALIZE_NON_INTRUSIVE()` with first
argument the namespace of your class, second argument the class name,
and the rest of the arguments listing the member variables. For example:

```cpp
// A type that's made serializable "intrusively", ie, by changing the type itself
namespace ns {
struct MyType
{
  int some_int;
  std::string some_string;
  std::vector<double> some_vector;
};
} // namespace ns

DUNE_DAQ_SERIALIZE_NON_INTRUSIVE(ns, MyType, some_int, some_string, some_vector);
```

A complete example, showing both intrusive and non-intrusive strategies, can be found in [`non_moo_type.cxx`](./test/apps/non_moo_type.cxx).

Full instructions for serializing arbitrary types with `nlohmann::json` are available [here](https://nlohmann.github.io/json/features/arbitrary_types/) and for `msgpack`, [here](https://github.com/msgpack/msgpack-c/wiki/v2_0_cpp_packer). These include instructions for (de)serializing classes that are not default-constructible.

## Design notes

Choice of serialization methods: there are many, many libraries and formats for serialization/deserialization, with a range of tradeoffs. I chose `nlohmann::json` and `msgpack` to get one human-readable format, and one faster binary format. `nlohmann::json` is chosen as the library for the human-readable format since it was already being used in DUNE DAQ code. For the binary format, I wanted a library that allows serialization of arbitrary types, rather than requiring types to be specified in, eg the library's DSL (this rules out, eg, `protobuf`). We may have to revisit that requirement if we find that `msgpack` does not meet performance requirements.

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Philip Rodrigues_

_Date: Mon Apr 19 11:04:14 2021 +0100_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/serialization/issues](https://github.com/DUNE-DAQ/serialization/issues)_
</font>
