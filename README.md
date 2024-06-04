# Struct Class

The Struct class is a versatile tool for managing structured data in Godot Engine. It provides a flexible way to define and manipulate data structures with typed properties, akin to a database table or a struct in traditional programming languages.

## Overview

The `Struct` class is an extendable `Resource` implementing Godot's server/resource pattern to provide highly memory optimized and type safe structs. Data is distributed into <Type>PackedArrays and is accessed through the structs index, which doubles as its unique ID. This convention allows for very fast lookups, on par with Godot's internal Classes, while maintaining a memory footprint more then 25x smaller then an identical `Object` and more then 35x smaller then an identical `Node2D`.


## Features

- **Typed Properties**: Define properties with specific data types such as strings, integers, floats, vectors, and colors.
- **Efficient Memory Management**: Utilizes Godot's packed arrays for efficient memory usage.
- **Dynamic Instance Management**: Easily create and manage multiple instances of structured data.
- **Property Management**: Add, remove, and clear properties dynamically.
- **Convenient Access Methods**: Access and manipulate data using property names or indices.
- **Extensible**: Easily extend the class to create custom structured data types.

## Usage

### Creating a Struct

```gdscript
var car := Struct.new([
    {"name":"make", "type":Struct.DataType.TypeString, "default":""},
    {"name":"model", "type":Struct.DataType.TypeString, "default":""},
    {"name":"year", "type":Struct.DataType.TypeInt32, "default":0},
    {"name":"color", "type":Struct.DataType.TypeColor, "default":Color.WHITE},
])
```

### Instance Management

```gdscript
car.instance_count = 20
var my_car := car.instance()
```

### Setting and Getting Properties

```gdscript
car.instance_set_property(my_car, "make", "Batmobile")
var my_car_make: String = car.instance_get_property(my_car, "make")
```

### Extending the Struct Class

```gdscript
class_name Car extends Struct

func _init():
    property_add("make", Struct.DataType.TypeString, "")

func new(make: String) -> int:
    return instance({"make":make})

func set_instance_make(instance_id: int, value: String) -> void:
    data[0][instance_id] = value

func get_instance_make(instance_id: int) -> String:
    return data[0][instance_id]
```

Now we can interact in a manner that's at least somewhat more object oriented:
```
var car := Car.new()
var my_car := car.new("KITT")
print( car.get_instance_make(my_car) ) # KITT

car.set_instance_make(my_car, "Batmobile")
print( car.get_instance_make(my_car) ) # Batmobile
```

### Clearing Struct Data

```gdscript
car.clear()
```

## Notes

- This class is marked as experimental and may undergo changes in future versions.
- For more detailed information, refer to the class documentation and comments in the source code.
