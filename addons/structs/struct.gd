@icon("res://addons/structs/Struct.svg")
class_name Struct extends Resource
## A struct implementation using the Server/Resource pattern.
##
## Structs are an abstraction over type safe, and highly memory efficient data pools.
## Creating a struct is done by passing in a list of Dictionary's describing the properties:
##
## [codeblock]
## var car := Struct.new([
##    {"name":"make", "type":Struct.DataType.TypeString, "default":""},
##    {"name":"model", "type":Struct.DataType.TypeString, "default":""},
##    {"name":"year", "type":Struct.DataType.TypeInt32, "default":0},
##    {"name":"color", "type":Struct.DataType.TypeColor, "default":Color.WHITE},
## ])
## [/codeblock]
##
## Instancing can be done by simply defining the number of instances, or more discretely with [method Struct.instance]
## [codeblock]
## car.instance_count = 20
## var my_car := car.instance()
## print( my_car ) # 20
## [/codeblock]
##
## Setting and Getting is done using Godot's Server pattern, using the index of the instance as id:
## [codeblock]
## car.instance_set_property(my_car, "make", "Batmobile")
## var my_car_make: String = car.instance_get_property(my_car, "make")
## print( my_car_make ) # Batmobile
## [/codeblock]
##
## Setting and Getting can be made more performant by using [method Struct.instance_get_at] and [method Struct.instance_set_at] methods:
## [codeblock]
## # The index of the property `make` matches the order in which we passed them to the struct in Struct.new()
## var make_property_index: int = 0
##
## car.instance_set_at(my_car, make_property_index, "Batmobile")
## var my_car_make: String = car.instance_get_at(my_car, make_property_index)
## print( my_car_make ) # Batmobile
## [/codeblock]
##
## This class becomes much friendlier when we extend it:
## [codeblock]
## class_name Car extends Struct
##
## func _init():
##    property_add("make", Struct.DataType.TypeString, "")
##
## func new(make: String) -> int:
##     return instance({"make":make})
##
## func set_instance_make(instance_id: int, value: String) -> void:
##     data[0][instance_id] = value
##
## func get_instance_make(instance_id: int) -> String:
##     return data[0][instance_id]
## [/codeblock]
##
## [codeblock]
## var car := Car.new()
## var my_car := car.new("KITT")
## print( car.get_instance_make(my_car) ) # KITT
##
## car.set_instance_make(my_car, "Batmobile")
## print( car.get_instance_make(my_car) ) # Batmobile
## [/codeblock]
##
## @experimental

const TYPE_64BIT = (1<<6)

## Valid data types the Struct class is built to handle.
enum DataType {
    ## Same as [enum Variant.Type.TYPE_STRING]
    TypeString = TYPE_STRING,
    ## Same as [enum Variant.Type.TYPE_INT]
    TypeInt64 = TYPE_INT | TYPE_64BIT,
    TypeInt32 = TYPE_INT,
    ## Same as [enum Variant.Type.TYPE_FLOAT]
    TypeFloat64 = TYPE_FLOAT | TYPE_64BIT,
    TypeFloat32 = TYPE_FLOAT,
    ## Same as [enum Variant.Type.TYPE_VECTOR2]
    TypeVector2 = TYPE_VECTOR2,
    ## Same as [enum Variant.Type.TYPE_VECTOR3]
    TypeVector3 = TYPE_VECTOR3,
    ## Same as [enum Variant.Type.TYPE_COLOR]
    TypeColor = TYPE_COLOR
}

## This is the table container. Each property appends a typed packed array where the values can be efficiently managed.
@export
var data: Array

## This is a list of [enum Struct.DataType] corresponding to the property with same index.
@export
var property_types: PackedInt32Array

## This list contains default values of the property with the matching index
@export
var property_defaults: Array

## This list contains the names of the property with the matching index
@export
var property_names: PackedStringArray

## The current number of instances. This is equivalent to the number of rows in a table.
@export
var instance_count      : int :
    set(value): ## When set, the table is simply resized. It drops the instances at the end if shrinking, or adds new empty rows at the bottom.
        instance_count = value
        for array in data:
            array.resize(instance_count)

func _init(properties:Array[Dictionary] = [], initial_instance_count:int = 0):
    for property in properties:
        assert(property.has("name"), "property is missing required parameter: `name: String`")
        assert(property.get("name") is String, "`name` property must be of type `String`")
        assert(property.has("type"), "property is missing required parameter: `type: DataType`")
        assert(property.get("type") is Struct.DataType, "property must be member of enum `DataType`")
        assert(property.has("default"), "property is missing required parameter: `default: Variant`")
        property_add(property.name, property.type, property.default)
    instance_count = initial_instance_count

## This method will completely wipe the struct, clearing both instance and property data.
func clear():
    data.clear()
    property_types.clear()
    property_defaults.clear()
    property_names.clear()
    instance_count = 0

## Adds a property column to the struct table.
func property_add(name: String, type: DataType, default: Variant=null) -> int:
    data.append(_type_get_packed_array(type, instance_count))
    var pid:int = property_names.size()
    property_names.append(name)
    property_defaults.append(_type_get_default(type) if default == null else default)
    property_types.append(type)
    return pid

## Removes a property column from the struct table.
func property_remove(pid: int) -> void:
    if pid < 0 or pid > property_names.size():
        return
    data.remove_at(pid)
    property_names.remove_at(pid)
    property_defaults.remove_at(pid)
    property_types.remove_at(pid)

## Clears a property of all it's data, resetting every instance's value to the default value for that property.
func property_clear(pid: int) -> void:
    if pid < 0 or pid > property_names.size():
        return
    data[pid].fill(property_defaults[pid])

## Get the name associated with the property of the given index.
func property_get_name(pid: int) -> String:
    if pid < 0 or pid > property_names.size():
        return ""
    return property_names[pid]

## Get the DataType associated with the property of the given index.
func property_get_type(pid: int) -> DataType:
    if pid < 0 or pid > property_names.size():
        return -1
    return property_types[pid]

## Get the default value associated with the property of the given index.
func property_get_default(pid: int) -> Variant:
    if pid < 0 or pid > property_names.size():
        return null
    return property_defaults[pid]

## Get the index of the property with the given name.
func property_get_id(property: String) -> int:
    return property_names.find(property)

## Increments the instance counter and returns the count. Useful abstraction for storing the id of particular instances:
## Can optionally pass in initial data in a dictionary: [code]{"property":"value"}[/code]
func instance(initial_data: Dictionary = {}) -> int:
    instance_count += 1
    for key in initial_data.keys():
        instance_set_property(instance_count, key, initial_data[key])
    return instance_count

func instance_set_property(sid: int, property: String, value: Variant) -> void:
    if !property_names.has(property):
        return
    data[property_names.find(property)][sid] = value

func instance_get_property(sid: int, property: String) -> Variant:
    if !property_names.has(property):
        return
    return data[property_names.find(property)][sid]

func instance_set_at(sid: int, pid:int, value: Variant) -> void:
    data[pid][sid] = value

func instance_get_at(sid: int, pid:int) -> Variant:
    return data[pid][sid]

func instance_get(sid: int) -> Array[Variant]:
    var res: Array[Variant]
    for pid in property_names.size():
        res.append(data[pid][sid])
    return res

func instance_set(sid: int, properties: Array[Variant]) -> void:
    for pid in properties.size():
        data[pid][sid] = properties[pid]

func instance_get_dict(sid: int) -> Dictionary:
    var res: Dictionary
    for pid in property_names.size():
        res[property_names[pid]] = data[pid][sid]
    return res

func instance_set_dict(sid: int, properties: Dictionary) -> void:
    for key in properties.keys():
        var pid := property_names.find(key)
        if pid == -1:
            continue
        data[pid][sid] = properties[key]

func instance_clear(sid: int) -> void:
    for i in property_names.size():
        data[i][sid] = property_defaults[i]

func _type_get_default(type: DataType) -> Variant:
    match type:
        DataType.TypeString:
            return ""
        DataType.TypeInt64:
            return 0
        DataType.TypeInt32:
            return 0
        DataType.TypeFloat64:
            return 0.0
        DataType.TypeFloat32:
            return 0.0
        DataType.TypeVector2:
            return Vector2.ZERO
        DataType.TypeVector3:
            return Vector3.ZERO
        DataType.TypeColor:
            return Color.WHITE
        _:
            return null

func _type_get_packed_array(type: DataType, size: int) -> Variant:
    match type:
        DataType.TypeString:
            var array: PackedStringArray
            array.resize(size)
            return array
        DataType.TypeInt64:
            var array: PackedInt64Array
            array.resize(size)
            return array
        DataType.TypeInt32:
            var array: PackedInt32Array
            array.resize(size)
            return array
        DataType.TypeFloat64:
            var array: PackedFloat64Array
            array.resize(size)
            return array
        DataType.TypeFloat32:
            var array: PackedFloat32Array
            array.resize(size)
            return array
        DataType.TypeVector2:
            var array: PackedVector2Array
            array.resize(size)
            return array
        DataType.TypeVector3:
            var array: PackedVector3Array
            array.resize(size)
            return array
        DataType.TypeColor:
            var array: PackedColorArray
            array.resize(size)
            return array
        _:
            return null

func _type_is_valid(type: int) -> bool:
    return type in DataType.values()
