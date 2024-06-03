extends Node2D

var start_time: float

func _ready() -> void:
    var count: int = 1_000_000
    var sets := generate_sets(100)

    print("sets hash: ", sets.hash())

    var sample_instance:int = randi_range(0, count-1)
    test_structs(count, sets, sample_instance)
    test_objects(count, sets, sample_instance)
    test_resources(count, sets, sample_instance)
    test_nodes(count, sets, sample_instance)
    test_node2ds(count, sets, sample_instance)

func test_structs(count: int, sets: Array[Dictionary], subject: int):
    var test := BaseStruct.new()
    test.add_property("editor_description", BaseStruct.DataType.TypeString, "some description")
    test.add_property("name", BaseStruct.DataType.TypeString, "TestStruct")
    test.add_property("process_mode", BaseStruct.DataType.TypeInt32, 1)
    test.add_property("process_physics_priority", BaseStruct.DataType.TypeInt32, 999)
    test.add_property("process_priority", BaseStruct.DataType.TypeInt32, 999)
    test.add_property("process_thread_group_order", BaseStruct.DataType.TypeInt32, 999)
    test.add_property("scene_file_path", BaseStruct.DataType.TypeString, "some/filepath/to/somewhere")
    var bmu := OS.get_static_memory_usage()

    time_start()
    for i in count:
        test.instance()
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for prop in sets:
        test.set_value(prop.property, subject, prop.value)
    var set_time := time_end()

    time_start()
    for prop in sets:
        test.get_value(prop.property, subject)
    var get_time := time_end()

    print("\nTest Results: Structs -----------------------")
    print("Number of instances: ", count)
    print("Construction time: ", construction_time)
    print("Memory usage: ", float(memory)/1_000_000, "mb")
    print("")
    print("Number of properties set: ", sets.size())
    print("Time to complete all sets: ", set_time)
    print("Average set time: ", set_time/sets.size())
    print("")
    print("Number of properties get: ", sets.size())
    print("Time to complete all gets: ", get_time)
    print("Average get time: ", get_time/sets.size())
    print("----------------------------------------------\n")


func test_objects(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(TestObject.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for prop in sets:
        list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for prop in sets:
        list[subject].get(prop.property)
    var get_time := time_end()

    for obj in list:
        obj.free()

    print("\nTest Results: Objects -----------------------")
    print("Number of instances: ", count)
    print("Construction time: ", construction_time)
    print("Memory usage: ", float(memory)/1_000_000, "mb")
    print("")
    print("Number of properties set: ", sets.size())
    print("Time to complete all sets: ", set_time)
    print("Average set time: ", set_time/sets.size())
    print("")
    print("Number of properties get: ", sets.size())
    print("Time to complete all gets: ", get_time)
    print("Average get time: ", get_time/sets.size())
    print("----------------------------------------------\n")

func test_resources(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(TestResource.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for prop in sets:
        list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for prop in sets:
        list[subject].get(prop.property)
    var get_time := time_end()

    print("\nTest Results: Resources ----------------------")
    print("Number of instances: ", count)
    print("Construction time: ", construction_time)
    print("Memory usage: ", float(memory)/1_000_000, "mb")
    print("")
    print("Number of properties set: ", sets.size())
    print("Time to complete all sets: ", set_time)
    print("Average set time: ", set_time/sets.size())
    print("")
    print("Number of properties get: ", sets.size())
    print("Time to complete all gets: ", get_time)
    print("Average get time: ", get_time/sets.size())
    print("----------------------------------------------\n")

func test_nodes(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(Node.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for prop in sets:
        list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for prop in sets:
        list[subject].get(prop.property)
    var get_time := time_end()

    for obj in list:
        obj.queue_free()

    print("\nTest Results: Nodes -------------------------")
    print("Number of instances: ", count)
    print("Construction time: ", construction_time)
    print("Memory usage: ", float(memory)/1_000_000, "mb")
    print("")
    print("Number of properties set: ", sets.size())
    print("Time to complete all sets: ", set_time)
    print("Average set time: ", set_time/sets.size())
    print("")
    print("Number of properties get: ", sets.size())
    print("Time to complete all gets: ", get_time)
    print("Average get time: ", get_time/sets.size())
    print("----------------------------------------------\n")

func test_node2ds(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(Node2D.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for prop in sets:
        list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for prop in sets:
        list[subject].get(prop.property)
    var get_time := time_end()

    for obj in list:
        obj.queue_free()

    print("\nTest Results: Node2Ds -----------------------")
    print("Number of instances: ", count)
    print("Construction time: ", construction_time)
    print("Memory usage: ", float(memory)/1_000_000, "mb")
    print("")
    print("Number of properties set: ", sets.size())
    print("Time to complete all sets: ", set_time)
    print("Average set time: ", set_time/sets.size())
    print("")
    print("Number of properties get: ", sets.size())
    print("Time to complete all gets: ", get_time)
    print("Average get time: ", get_time/sets.size())
    print("----------------------------------------------\n")

func time_start() -> float:
    start_time = Time.get_unix_time_from_system()
    return start_time

func time_end() -> float:
    return Time.get_unix_time_from_system() - start_time

func generate_sets(count: int) -> Array[Dictionary]:
    var rng := RandomNumberGenerator.new()
    rng.seed = 69420
    var props = [
        "editor_description",
        "name",
        "process_mode",
        "process_physics_priority",
        "process_priority",
        "process_thread_group_order",
        "scene_file_path"
    ]
    var result: Array[Dictionary]
    var abc: String = "abcdefghijklmnopqrstuvwxyz"
    for x in count:
        var prop: String = props[rng.randi_range(0, props.size()-1)]
        match prop:
            "editor_description", "scene_file_path", "name":
                var value: String
                for i in rng.randi_range(12, 24):
                    value += abc[rng.randi_range(0, abc.length()-1)]
                result.append({"property": prop, "value": value})
            "process_mode", "process_physics_priority", "process_priority", "process_thread_group_order":
                result.append({"property": prop, "value": rng.randi()})

    return result


class TestObject extends Object:
    var editor_description: String = "some description"
    var name: String = "TestObject"
    var process_mode: int = 1
    var process_physics_priority: int = 999
    var process_priority: int = 999
    var process_thread_group_order: int = 999
    var scene_file_path: String = "some/filepath/to/somewhere"

class TestResource extends Resource:
    var editor_description: String = "some description"
    var name: String = "TestObject"
    var process_mode: int = 1
    var process_physics_priority: int = 999
    var process_priority: int = 999
    var process_thread_group_order: int = 999
    var scene_file_path: String = "some/filepath/to/somewhere"
