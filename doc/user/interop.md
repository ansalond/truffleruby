# Truffle Interop

TruffleRuby supports standard Truffle interop messages. This document explains
what it does when it receives them, how to get it to explicitly send them, how
to get it to send them using more idiomatic Ruby, and how what messages it sends
for normal Ruby operations on foreign objects.

Interop ignores visibility entirely.

* [How Ruby responds to messages](#how-ruby-responds-to-messages)
* [How to explicitly send messages from Ruby](#how-to-explicitly-send-messages-from-ruby)
* [How to send messages using idiomatic Ruby](#how-to-send-messages-using-idiomatic-ruby)
* [What messages are sent for Ruby syntax on foreign objects](#what-messages-are-sent-for-ruby-syntax-on-foreign-objects)
* [Import and export](#import-and-export)
* [Interop eval](#interop-eval)
* [Additional methods](#additional-methods)
* [Notes on method resolution](#notes-on-method-resolution)

## How Ruby responds to messages

### `IS_EXECUTABLE`

Returns true only for instances of `Method` and `Proc`.

### `EXECUTE`

Calls either a `Method` or `Proc`, passing the arguments as you'd expect.
Doesn't pass a block.

### `INVOKE`

Calls the method with the name you provided, passing the arguments as you'd
expect. Doesn't pass a block.

### `NEW`

Calls `new`, passing the arguments as you'd expect.

### `HAS_SIZE`

Returns true if the object responds to `size`.

### `GET_SIZE`

Call `size` on the object.

### `IS_BOXED`

Returns true only for instances of `String`, `Rubinius::FFI::Pointer` and
objects that respond to `unbox`.

### `UNBOX`

For a `String`, produces a `java.lang.String`, similar to
`Truffle::Interop.to_java_string`. For a `Rubinius::FFI::Pointer`, produces the
address as a `long`. For all other objects calls `unbox`.

### `IS_POINTER`

Returns true only for `FFI::Pointer`.

### `AS_POINTER`

Calls `address` if the object responds to it, otherwise throws
`UnsupportedMessageException`.

### `TO_NATIVE`

Calls `to_native` if the object responds to it, otherwise throws
`UnsupportedMessageException`.

### `IS_NULL`

Returns true only for the `nil` object.

### `KEYS`

If the receiver is a Ruby `Hash`, return the hash keys.

`KEYS(hash)` → `hash.keys`

Otherwise, return the instance variable names, without the leading `@`.

`KEYS(other)` → `other.instance_variables.map { |key| key[1..-1 }`

In both cases the keys are returned as a Ruby `Array` containing Java `String`
objects.

### `READ`

The name must be a Java `int` or `String`, or a Ruby `String` or `Symbol`.

If the receiver is a Ruby `String` and the name is an integer, read a byte from
the string, ignoring the encoding. If the index is out of range you'll get 0:

`READ(string, integer)` → `string.get_byte(integer)`

Otherwise, if the name starts with `@`, read it as an instance variable:

`READ(object, "@name")` → `object.instance_variable_get("name")`

Otherwise, if there isn't a method defined on the object with the same name as
the name, perform a method call using the name as the called method name:

`READ(object, name)` → `object.name` if `object.responds_to?(name)`

Otherwise, if there isn't a method defined on the object with the same name as
the name, and there is a method defined on the object called `[]`, call `[]`
with the name as the argument:

`READ(object, name)` → `object[name]` unless `object.responds_to?(name)`

Otherwise throws `UnknownIdentifierException`.

In all cases where a call is made no block is passed.

An exception during a read will result in an `UnknownIdentifierException`.

### `WRITE`

The name must be a Java `String`, or a Ruby `String` or `Symbol`.

If the name starts with `@`, write it as an instance variable:

`WRITE(object, "@name", value)` → `object.instance_variable_set("name", value)`

Otherwise, if there is a method defined on the object with the same name as
the name appended with `=`, perform a method call using the name appended with
`=` as the called method name, and the value as the argument:

`WRITE(object, name, value)` → `object.name = value` if
`object.responds_to?(name + "=")`

Otherwise, if there isn't a method defined on the object with the same name as
the name appended with `=`, and there is a method defined on the object called
`[]=`, call `[]=` with the name and value as the two arguments:

`WRITE(object, name, value)` → `object[name] = value` if
`object.responds_to?("[]=")` and unless
`object.responds_to?(name + "=")`

Otherwise throws `UnknownIdentifierException`.

In all cases where a call is made no block is passed.

## How to explicitly send messages from Ruby

### `IS_EXECUTABLE`

`Truffle::Interop.executable?(value)`

### `EXECUTE`

`Truffle::Interop.execute(receiver, *args)`

### `INVOKE`

`Truffle::Interop.invoke(receiver, name, *args)`

`name` can be a `String` or `Symbol`.

### `NEW`

`Truffle::Interop.new(receiver, *args)`

### `HAS_SIZE`

`Truffle::Interop.size?(value)`

### `GET_SIZE`

`Truffle::Interop.size(value)`

### `IS_BOXED`

`Truffle::Interop.boxed?(value)`

### `UNBOX`

`Truffle::Interop.unbox(value)`

### `IS_POINTER`

`Truffle::Interop.pointer?(value)`

### `AS_POINTER`

`Truffle::Interop.as_pointer(value)`

### `TO_NATIVE`

`Truffle::Interop.to_native(value)`

### `IS_NULL`

`Truffle::Interop.null?(value)`

### `KEYS`

`Truffle::Interop.keys(value)`

TruffleRuby will convert the returned value from a foreign object of Java
`String` objects, to a Ruby `Array` of Ruby `String` objects.

### `READ`

`Truffle::Interop.read(object, name)`

If `name` is a `String` or `Symbol` it will be converted into a Java `String`.

### `WRITE`

`Truffle::Interop.read(object, name, value)`

If `name` is a `String` or `Symbol` it will be converted into a Java `String`.

## How to send messages using idiomatic Ruby

### `IS_EXECUTABLE`

Not supported.

### `EXECUTE`

`object.call(*args)`

### `INVOKE`

`object.name(*args)`

`object.name!` if there are no arguments (otherwise it is a `READ`)

### `NEW`

`object.new(*args)`

### `HAS_SIZE`

Not supported.

### `GET_SIZE`

Not supported.

### `IS_BOXED`

Not supported.

### `UNBOX`

Not supported.

### `IS_POINTER`

Not supported.

### `AS_POINTER`

Not supported.

### `TO_NATIVE`

Not supported.

### `IS_NULL`

`value.nil?`

### `KEYS`

Not supported.

### `READ`

`object.name`

`object[name]`, where name is a `String` or `Symbol` in most cases, or an
integer, or anything else

### `WRITE`

`object.name = value`

`object[name] = value`, where name is a `String` or `Symbol` in most cases, or
an integer, or anything else

## What messages are sent for Ruby syntax on foreign objects

`object[name]` (`#[](name)`) sends `READ`

`object.name` with no arguments send `READ`

`object[name] = value` (`#[]=(name, value)`) sends `WRITE`

`object.name = value` (a message name matching `.*[^=]=`, such as `name=`, and with just one argument) sends `WRITE`

`object.call(*args)` sends `EXECUTE`

`object.nil?` sends `IS_NIL`

`object.name(*args)` sends `INVOKE` (with no arguments it sends `READ`)

`object.name!` sends `INVOKE`

`object.new(*args)` sends `NEW`

`object.respond_to?` calls `Truffle::Interop.respond_to?(object, message)`

`object.to_a` and `object.to_ary` calls `Truffle::Interop.to_array(object)`

`object.inspect` produces a simple string of the format
`#<Truffle::Interop::Foreign:system-identity-hash-code>`

`object.__send__(name, *args)` works in the same way as literal method call on the
foreign object, including allowing the special-forms listed above (see
[notes on method resolution](#notes-on-method-resolution)).

## Import and export

`Truffle::Interop.export(:name, value)`

`Truffle::Interop.export_method(:name)` (looks for `name` in `Object`)

`value = Truffle::Interop.import(:name)`

`Truffle::Interop.import_method(:name)` (defines `name` in `Object`)

## Interop Eval

`Truffle::Interop.eval(mime_type, source)`

`Truffle::Interop.import_file(path)` evals an entire file, guessing the correct
language MIME type.

## Additional methods

`Truffle::Interop.foreign?(object)`

`Truffle::Interop.mime_type_supported?(mime_type)` reports if a language's MIME
type is supported for interop.

`Truffle::Interop.java_string?(object)`

`Truffle::Interop.to_java_string(ruby_string)`

`Truffle::Interop.from_java_string(java_string)`

`Truffle::Interop.object_literal(a: 1, b: 2, c: 3...)` gives you a simple object
with these fields and values, like a JavaScript object literal does. You can
then continue to read and write fields on the object and they will be
dynamically added, similar to `OpenStruct`.

`Truffle::Interop.enumerable(object)` gives you an `Enumerable` interface to a
foreign object.

`Truffle::Interop.to_java_array(array)` gives you a proxied Java array copied
from the Ruby array.

`Truffle::Interop.java_array(a, b, c...)` a literal variant of the former.

`Truffle::Interop.deproxy(object)` deproxy a Java object if it has been proxied.

`Truffle::Interop.to_array(object)` converts to a Ruby array by calling
`GET_SIZE` and sending `READ` for each index from zero to the size.

`Truffle::Interop.respond_to?(object, name)` sends `HAS_SIZE` for `to_a` or
`to_ary`, or `false` otherwise. Note that this means that many interop objects
may have methods you can call that they do not report to respond to.

`Truffle::Interop.meta_object(object)` returns the Truffle meta-object that
describes the object (unrelated to the metaclass);

## Notes on method resolution

Method calls on foreign objects are usually translated exactly into foreign
`READ`, `INVOKE` and other messages. The other methods listed in
[what messages are sent for Ruby syntax on foreign objects](#what-messages-are-sent-for-ruby-syntax-on-foreign-objects)
are a kind of special-form - they are implemented as a special case in the
call-site logic. They are not being provided by `BasicObject` or `Kernel` as you
may expect. This means that for example `#method` isn't available, and you can't
use it to get the method for `#to_a` on a foreign object, as it it's a
special-form, not a method.
