class_name BaseStruct extends Resource

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


func instance() -> int:
    var id: int = _count
    _count += 1
    for property in _data.keys():
        _data[property].append(_property_defaults[property])
    return id

func delete(sid: int) -> void:
    for property in _data.keys():
        _data[property].remove_at(sid)
    if sid in _signals:
        _signals.erase(sid)

func clear() -> void:
    _data.clear()
    _property_defaults.clear()
    _property_types.clear()
    _count = 0

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
        DataType.TypeInt64:
            _data[name] = PackedInt64Array()
        DataType.TypeInt32:
            _data[name] = PackedInt32Array()
        DataType.TypeFloat64:
            _data[name] = PackedFloat32Array()
        DataType.TypeFloat32:
            _data[name] = PackedFloat64Array()
        DataType.TypeVector2:
            _data[name] = PackedVector2Array()
        DataType.TypeVector3:
            _data[name] = PackedVector3Array()
        DataType.TypeColor:
            _data[name] = PackedColorArray()

func set_value(property: String, sid: int, value: Variant) -> void:
    _data[property][sid] = value
    if sid in _signals:
        for cb in _signals[sid]:
            cb.call(sid)

func get_value(property: String, sid:int) -> Variant:
    return _data[property][sid]

func changed_connect(sid: int, callback: Callable) -> void:
    _signals[sid] = _signals.get(sid, []).append(callback)

func changed_disconnect(sid: int, callback: Callable) -> void:
    if sid in _signals:
        if callback in _signals[sid]:
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

