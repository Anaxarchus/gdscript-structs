class_name TestStruct extends BaseStruct


func _init() -> void:
    add_property("position", DataType.TypeVector3, Vector3.ZERO)
    add_property("rotation", DataType.TypeVector3, Vector3.ZERO)
    add_property("scale", DataType.TypeVector3, Vector3.ZERO)

func set_position(id: int, value: Vector3) -> void:
    _data["position"][id] = value

func set_rotation(id: int, value: Vector3) -> void:
    _data["rotation"][id] = value

func set_scale(id: int, value: Vector3) -> void:
    _data["scale"][id] = value

func get_position(id: int) -> Vector3:
    return _data["position"][id]

func get_rotation(id: int) -> Vector3:
    return _data["rotation"][id]

func get_scale(id: int) -> Vector3:
    return _data["scale"][id]
