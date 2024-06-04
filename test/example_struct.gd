class_name ExampleStruct extends Struct

const PropertyPosition: int = 0
const PropertyRotation: int = 1
const PropertyScale: int = 2

func _init() -> void:
    property_add("position", DataType.TypeVector3, Vector3.ZERO)
    property_add("rotation", DataType.TypeVector3, Vector3.ZERO)
    property_add("scale", DataType.TypeVector3, Vector3.ZERO)

func set_position(struct_id: int, value: Vector3) -> void:
    data[PropertyPosition][struct_id] = value

func set_rotation(struct_id: int, value: Vector3) -> void:
    data[PropertyRotation][struct_id] = value

func set_scale(struct_id: int, value: Vector3) -> void:
    data[PropertyScale][struct_id] = value

func get_position(struct_id: int) -> Vector3:
    return data[PropertyPosition][struct_id]

func get_rotation(struct_id: int) -> Vector3:
    return data[PropertyRotation][struct_id]

func get_scale(struct_id: int) -> Vector3:
    return data[PropertyScale][struct_id]
