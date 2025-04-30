# DUNE DAQ C++ object serialization utilities

This repository contains utilities for serializing/deserializing C++ objects for DUNE DAQ. Serialization allows objects to be sent across the network or persisted to disk.

## Quick start

An appropriately-defined C++ type (see below) can be serialized/deserialized as follows:

```cpp
 MyClass m;
 m.some_member=3;
 // ... set other parts of m...
 dunedaq::serialization::SerializationType stype=dunedaq::serialization::kMsgPack; // MsgPack is only supported option for now
 std::vector<uint8_t> bytes=dunedaq::serialization::serialize(m, stype);
 
 // ...elsewhere, after receiving the serialized object:
 MyClass m_recv=dunedaq::serialization::deserialize<MyClass>(bytes);
```

## Making types serializable

Classes can be made serializable by adding convertor functions for `msgpack`.

The easiest way to make your class (de)serializable is with the `DUNE_DAQ_SERIALIZE()` and `DUNE_DAQ_SERIALIZABLE()` convenience macros provided in [`Serialization.hpp`](./include/serialization/Serialization.hpp):

```cpp
// A type that's made serializable "intrusively", ie, by changing the type itself
namespace dunedaq {
namespace ns {
struct MyTypeIntrusive
{
  int some_int;
  std::string some_string;
  std::vector<double> some_vector;

  DUNE_DAQ_SERIALIZE(MyTypeIntrusive, some_int, some_string, some_vector);
};
} // namespace ns

DUNE_DAQ_SERIALIZABLE(ns::MyTypeIntrusive, "MyTypeIntrusive"); // should be in the dunedaq namespace
} // namespace dunedaq
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

A complete example, showing both intrusive and non-intrusive strategies, can be found in [`serialization_simple_test.cxx`](./test/apps/serialization_simple_test.cxx).

Full instructions for serializing arbitrary types with `msgpack` are available [here](https://github.com/msgpack/msgpack-c/wiki/v2_0_cpp_packer). These include instructions for (de)serializing classes that are not default-constructible. Several custom serializers have been implemented, such as [Fragment_serialization.hpp](https://github.com/DUNE-DAQ/dfmessages/blob/develop/include/dfmessages/Fragment_serialization.hpp) in `dfmessages`.

## Design notes

Choice of serialization methods: there are many, many libraries and formats for serialization/deserialization, with a range of tradeoffs. For the binary format, we wanted a library that allows serialization of arbitrary types, rather than requiring types to be specified in, eg the library's DSL (this rules out, eg, `protobuf`). We may have to revisit that requirement if we find that `msgpack` does not meet performance requirements.


-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Eric Flumerfelt_

_Date: Thu Mar 27 08:20:37 2025 -0500_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/serialization/issues](https://github.com/DUNE-DAQ/serialization/issues)_
</font>
