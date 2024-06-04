# Struct Class

## Overview

The `Struct` class is an extendable `Resource` implementing Godot's server/resource pattern to provide highly memory optimized and type safe structs. Data is distributed into <Type>PackedArrays and is accessed through the structs index, which doubles as its unique ID. This convention allows for very fast lookups, on par with Godot's internal Classes, while maintaining a memory footprint more then 25x smaller then an identical `Object` and more then 35x smaller then an identical `Node2D`.



## Usage

### Working directly with Struct

Using the `Struct` is straightforward.
```
var spatial := Struct.new([
    "position": {"type": Struct.DataType.Vector3, "default": Vector3.ZERO},
    "rotation": {"type": Struct.DataType.Vector3, "default": Vector3.ZERO},
    "scale": {"type": Struct.DataType.Vector3, "default": Vector3.ZERO},
])
```

Managing your instances works much the same as it does with a `MultiMeshInstance`:
```
spatial.instance_count = 1000
```

Updating can be done in one of two ways, either through the property name itself:
```
spatial.instance_set_property("position", instance_index, Vector3(1, 1, 1))
```

Or more performantly through the properties index:
```
# Since `position` was the first property we passed, it's index is 0.
spatial.instance_set_at(0, instance_index, Vector3(1, 1, 1))
```

### Extending Struct

Extending the struct class can be very convenient for enabling editor hints:
```
class_name SpatialStruct extends Struct

func _init():
    property_add("position", DataType.TypeVector3, Vector3.ZERO)
    property_add("rotation", DataType.TypeVector3, Vector3.ZERO)
    property_add("scale", DataType.TypeVector3, Vector3.ZERO)

func get_position(instance_id: int, value: Vector3) -> void:
    data[0][instance_id] = value

func get_position(instance_id: int) -> Vector3:
    return data[0][instance_id]
```
