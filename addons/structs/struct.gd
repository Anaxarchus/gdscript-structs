@icon("res://addons/structs/Struct.svg")
class_name Struct extends Resource
## A struct implementation using the Server/Resource pattern.
##
## Structs are an abstraction over type safe, and highly memory efficient data pools.
##
## For usage examples and help, see README.md.
## @tutorial:            https://github.com/Anaxarchus/gdscript-structs
## @experimental

enum DataType {
    TypeString,
    TypeInt64,
    TypeInt32,
    TypeFloat64,
    TypeFloat32,
    TypeVector2,
    TypeVector3,
    TypeColor
}

@export
var data               : Dictionary
@export
var property_defaults  : Dictionary
@export
var property_types     : Dictionary
@export
var signals            : Dictionary
@export
var count              : int

func property_get_type(property: String) -> DataType:
    return property_types[property]

func property_get_default(property: String) -> Variant:
    return property_defaults[property]

func property_set_default(property: String, value: Variant) -> void:
    property_defaults[property] = value

func add_property(name: String, type: DataType, default: Variant=null) -> void:
    property_defaults[name] = _get_default_value(type) if default == null else default
    property_types[name] = type
    match type:
        DataType.TypeString:
            data[name] = PackedStringArray()
            data[name].resize(count)
        DataType.TypeInt64:
            data[name] = PackedInt64Array()
            data[name].resize(count)
        DataType.TypeInt32:
            data[name] = PackedInt32Array()
            data[name].resize(count)
        DataType.TypeFloat64:
            data[name] = PackedFloat32Array()
            data[name].resize(count)
        DataType.TypeFloat32:
            data[name] = PackedFloat64Array()
            data[name].resize(count)
        DataType.TypeVector2:
            data[name] = PackedVector2Array()
            data[name].resize(count)
        DataType.TypeVector3:
            data[name] = PackedVector3Array()
            data[name].resize(count)
        DataType.TypeColor:
            data[name] = PackedColorArray()
            data[name].resize(count)

func _instance() -> int:
        for property in data.keys():
            data[property].append(count, property_defaults[property])
        count += 1
        return count-1

func instance() -> int:
    return _instance()

func batch_instance(group_size: int) -> void:
    for prop in data.keys():
        data[prop].resize(count + group_size)
    var id := WorkerThreadPool.add_group_task(_instance, group_size)
    WorkerThreadPool.wait_for_group_task_completion(id)

## Deleting an instance simply zeroes its data, reducing its overhead but leaving it's column in place
## so as not to shift the indices of other instances.
func delete(sid: int) -> void:
    for property in data.keys():
        data[property] = property_defaults[property]
    if sid in signals:
        signals.erase(sid)

## Clears all instance data.
func clear() -> void:
    data.clear()
    count = 0

func set_value(property: String, sid: int, value: Variant) -> void:
    data[property][sid] = value
    if sid in signals:
        _changed_call(sid)

func get_value(property: String, sid:int) -> Variant:
    return data[property][sid]

## At the moment, the only flags implemented are None and Deferred.
func changed_connect(sid: int, callback: Callable, flags: Object.ConnectFlags = 0) -> void:
    var sig_hash := callback.hash()
    var sid_sigs: Dictionary = signals.get(sid, {})
    var sig_dat: Dictionary = sid_sigs.get(sig_hash, {})
    sig_dat["callback"] = callback
    sig_dat["flags"] = flags
    sid_sigs[sig_hash] = sig_dat
    signals[sid] = sid_sigs

func changed_disconnect(sid: int, callback: Callable) -> void:
    if signals.has(sid):
        if signals[sid].has(callback):
            signals[sid].erase(callback)
            if signals[sid].is_empty():
                signals.erase(sid)

func get_instance_as_dictionary(sid: int) -> Dictionary:
    var res: Dictionary
    for property in data.keys():
        res[property] = data[property][sid]
    return res

func print_instance(sid: int) -> void:
    print(get_instance_as_dictionary(sid))

func _get_default_value(type: DataType) -> Variant:
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

func _changed_call(sid: int) -> void:
    for key in signals.get(sid, {}).keys():
        if signals[sid][key]["flags"] == Object.CONNECT_DEFERRED:
            signals[sid][key]["callback"].call_deferred(sid)
        else:
            signals[sid][key]["callback"].call(sid)
