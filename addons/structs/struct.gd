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

var _data               : Dictionary
var _property_defaults  : Dictionary
var _property_types     : Dictionary
var _signals            : Dictionary
var _count              : int
var _free_id            : PackedInt64Array

func property_get_type(property: String) -> DataType:
    return _property_types[property]

func property_get_default(property: String) -> Variant:
    return _property_defaults[property]

func property_set_default(property: String, value: Variant) -> void:
    _property_defaults[property] = value

func add_property(name: String, type: DataType, default: Variant=null) -> void:
    _property_defaults[name] = _get_default_value(type) if default == null else default
    _property_types[name] = type
    match type:
        DataType.TypeString:
            _data[name] = PackedStringArray()
            _data[name].resize(_count)
        DataType.TypeInt64:
            _data[name] = PackedInt64Array()
            _data[name].resize(_count)
        DataType.TypeInt32:
            _data[name] = PackedInt32Array()
            _data[name].resize(_count)
        DataType.TypeFloat64:
            _data[name] = PackedFloat32Array()
            _data[name].resize(_count)
        DataType.TypeFloat32:
            _data[name] = PackedFloat64Array()
            _data[name].resize(_count)
        DataType.TypeVector2:
            _data[name] = PackedVector2Array()
            _data[name].resize(_count)
        DataType.TypeVector3:
            _data[name] = PackedVector3Array()
            _data[name].resize(_count)
        DataType.TypeColor:
            _data[name] = PackedColorArray()
            _data[name].resize(_count)

## When an instance is destroyed, it's values are zeroed but its indices are left in place.
## In testing, I found that using indices was the only way to achieve competitive get/set speeds.
## For this reason, instances are ID'd by their index, and therefore indices cannot be allowed to shift
## when an instance is destroyed. Those columns will be tracked, and new instances will attempt
## to reclaim them.
func _instance(reclaim_memory: bool) -> int:
    if _free_id.is_empty() or !reclaim_memory:
        for property in _data.keys():
            _data[property].append(_count, _property_defaults[property])
        _count += 1
        return _count-1
    else:
        var id := _free_id[0]
        _free_id.remove_at(0)
        return id

## Single instances will attempt to reclaim memory
func instance() -> int:
    return _instance(true)

## Batch instances will use a fresh contiguous block, not attempting to reclaim memory.
# TODO: look into thread safe ways of reclaiming memory.
func batch_instance(group_size: int) -> void:
    for prop in _data.keys():
        _data[prop].resize(_count + group_size)
    var id := WorkerThreadPool.add_group_task(_instance.bind(false), group_size)
    WorkerThreadPool.wait_for_group_task_completion(id)

## Deleting an instance simply zeroes its data, reducing its overhead but leaving it's column in place
## so as not to shift the indices of other instances. This memory can be reclaimed later.
func delete(sid: int) -> void:
    for property in _data.keys():
        _data[property] = _property_defaults[property]
    if sid in _signals:
        _signals.erase(sid)

## Clears all instance data.
func clear() -> void:
    _data.clear()
    _count = 0

func set_value(property: String, sid: int, value: Variant) -> void:
    _data[property][sid] = value
    if sid in _signals:
        _changed_call(sid)

func get_value(property: String, sid:int) -> Variant:
    return _data[property][sid]

## At the moment, the only flags implemented are None and Deferred.
func changed_connect(sid: int, callback: Callable, flags: Object.ConnectFlags = 0) -> void:
    var sig_hash := callback.hash()
    var sid_sigs: Dictionary = _signals.get(sid, {})
    var sig_dat: Dictionary = sid_sigs.get(sig_hash, {})
    sig_dat["callback"] = callback
    sig_dat["flags"] = flags
    sid_sigs[sig_hash] = sig_dat
    _signals[sid] = sid_sigs

func changed_disconnect(sid: int, callback: Callable) -> void:
    if _signals.has(sid):
        if _signals[sid].has(callback):
            _signals[sid].erase(callback)
            if _signals[sid].is_empty():
                _signals.erase(sid)

func get_instance_as_dictionary(sid: int) -> Dictionary:
    var res: Dictionary
    for property in _data.keys():
        res[property] = _data[property][sid]
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
    for key in _signals.get(sid, {}).keys():
        if _signals[sid][key]["flags"] == Object.CONNECT_DEFERRED:
            _signals[sid][key]["callback"].call_deferred(sid)
        else:
            _signals[sid][key]["callback"].call(sid)
