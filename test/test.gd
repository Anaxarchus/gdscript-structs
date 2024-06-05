extends Node2D


# Number of set calls to generate
const SetSamples:int = 100
# Number of Objects to call the set calls on
const ObjectSamples:int = 1000
var start_time: float

var output: String



func _ready() -> void:
    var which:int = 4
    var count: int = 100_000
    #var count: int = 250_000
    #var count: int = 500_000
    #var count: int = 1_000_000
    var sets := generate_sets(SetSamples)

    #output += "CPU: " + OS.get_processor_name() + "\n"
    #output += ("Times Averaged from {0} property queries in each of {1} Object instances for a total of {2} samples\n\n".format([SetSamples, ObjectSamples, SetSamples*ObjectSamples]))
    #print("")
    #output += "| Type | Count | Data Hash | Usage (mb) | Set Time (nanoseconds) | Get Time (nanoseconds) |\n"
    #output += "|______|_______|___________|____________|________________________|________________________|\n"
    output = FileAccess.get_file_as_string("res://test/benchmarks.txt")

    var sample_instance:int = randi_range(0, count-1)
    match which:
        0:
            test_structs(count, sets, sample_instance)
        1:
            test_objects(count, sets, sample_instance)
        2:
            test_resources(count, sets, sample_instance)
        3:
            test_nodes(count, sets, sample_instance)
        4:
            test_node2ds(count, sets, sample_instance)

    var file := FileAccess.open("res://test/benchmarks.txt", FileAccess.WRITE)
    if file != null:
        file.store_string(output)
        file.close()
    else:
        print("could not store data: ", FileAccess.get_open_error())
        ERR_PARSE_ERROR
    print_rich("[color=green]Finished[/color]")

func test_structs(count: int, sets: Array[Dictionary], subject: int):
    var struct := Struct.new([
        { "name": "editor_description", "type": Struct.DataType.TypeString, "default": "some description" },
        { "name": "name", "type": Struct.DataType.TypeString, "default": "TestStruct" },
        { "name": "process_mode", "type": Struct.DataType.TypeInt32, "default": 999 },
        { "name": "process_physics_priority", "type": Struct.DataType.TypeInt32, "default": 999 },
        { "name": "process_priority", "type": Struct.DataType.TypeInt32, "default": 999 },
        { "name": "process_thread_group_order", "type": Struct.DataType.TypeInt32, "default": 999 },
        { "name": "scene_file_path", "type": Struct.DataType.TypeString, "default": "some/filepath/to/somewhere" },
    ])
    var bmu := OS.get_static_memory_usage()

    time_start()
    struct.instance_count = count
    var construction_time := time_end()

    time_start()
    for x in ObjectSamples:
        for row in sets:
            struct.instance_set_property(subject, row.property, row.value)
    var set_property_time := time_end()

    var pids := sets.duplicate(true)
    for x in pids.size():
        pids[x].property = struct.property_get_id(pids[x].property)

    time_start()
    for x in ObjectSamples:
        for row in pids:
            struct.instance_set_at(subject, row.property, row.value)
    var set_at_time := time_end()

    time_start()
    for x in ObjectSamples:
        for row in sets:
            struct.instance_get_property(subject, row.property)
    var get_property_time := time_end()

    time_start()
    for x in ObjectSamples:
        for row in pids:
            struct.instance_get_at(subject, row.property)
    var get_at_time := time_end()

    var memory := OS.get_static_memory_usage()

    print_results("Struct (using property name)", count, sets.hash(), float(memory-bmu), set_property_time, get_property_time)
    print_results("Struct (using property index)", count, sets.hash(), float(memory-bmu), set_at_time, get_at_time)

    #print("\nTest Results: Structs -----------------------")
    #print("Number of instances: ", count)
    #print("Construction time: ", construction_time)
    #print("")
    #print("Total Memory Used Before Instancing: ", float(bmu)/1_000_000, "mb")
    #print("Total Memory Used After Instancing: ", float(memory)/1_000_000, "mb")
    #print("    Struct Memory Usage: ", float(memory-bmu)/1_000_000, "mb")
    #print("")
    #print("Number of properties set: ", sets.size())
    #print("    Time to set all instances using property: ", set_property_time)
    #print("    Average set property time per instance: ", set_property_time/sets.size())
    #print("")
    #print("    Time to set all instances using index: ", set_at_time)
    #print("    Average set at time per instance: ", set_at_time/sets.size())
    #print("")
    #print("Number of properties get: ", sets.size())
    #print("    Time to get all instances using property: ", get_property_time)
    #print("    Average get property time per instance: ", get_property_time/sets.size())
    #print("")
    #print("    Time to get all instances using index: ", get_at_time)
    #print("    Average get at time per instance: ", get_at_time/sets.size())
    #print("----------------------------------------------\n")


func test_objects(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(TestObject.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].get(prop.property)
    var get_time := time_end()

    for obj in list:
        obj.free()

    print_results("Object", count, sets.hash(), float(memory-bmu), set_time, get_time)

    #print("\nTest Results: Objects -----------------------")
    #print("Number of instances: ", count)
    #print("    Memory usage: ", float(memory)/1_000_000, "mb")
    #print("")
    #print("Number of properties set: ", sets.size())
    #print("    Time to complete all sets: ", set_time)
    #print("    Average set time: ", set_time/sets.size())
    #print("")
    #print("Number of properties get: ", sets.size())
    #print("    Time to complete all gets: ", get_time)
    #print("    Average get time: ", get_time/sets.size())
    #print("----------------------------------------------\n")

func test_resources(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(TestResource.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].get(prop.property)
    var get_time := time_end()

    print_results("Resource", count, sets.hash(), float(memory-bmu), set_time, get_time)

    #print("\nTest Results: Resources ----------------------")
    #print("Number of instances: ", count)
    #print("    Memory usage: ", float(memory)/1_000_000, "mb")
    #print("")
    #print("Number of properties set: ", sets.size())
    #print("    Time to complete all sets: ", set_time)
    #print("    Average set time: ", set_time/sets.size())
    #print("")
    #print("Number of properties get: ", sets.size())
    #print("    Time to complete all gets: ", get_time)
    #print("    Average get time: ", get_time/sets.size())
    #print("----------------------------------------------\n")

func test_nodes(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(Node.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].get(prop.property)
    var get_time := time_end()

    for obj in list:
        obj.queue_free()

    print_results("Node", count, sets.hash(), float(memory-bmu), set_time, get_time)

    #print("\nTest Results: Nodes -------------------------")
    #print("Number of instances: ", count)
    #print("    Memory usage: ", float(memory)/1_000_000, "mb")
    #print("")
    #print("Number of properties set: ", sets.size())
    #print("    Time to complete all sets: ", set_time)
    #print("    Average set time: ", set_time/sets.size())
    #print("")
    #print("Number of properties get: ", sets.size())
    #print("    Time to complete all gets: ", get_time)
    #print("    Average get time: ", get_time/sets.size())
    #print("----------------------------------------------\n")

func test_node2ds(count: int, sets: Array[Dictionary], subject: int):
    var bmu := OS.get_static_memory_usage()
    var list: Array

    time_start()
    for i in count:
        list.append(Node2D.new())
    var construction_time := time_end()
    var memory := OS.get_static_memory_usage() - bmu

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].set(prop.property, prop.value)
    var set_time := time_end()

    time_start()
    for x in ObjectSamples:
        for prop in sets:
            list[subject].get(prop.property)
    var get_time := time_end()

    for obj in list:
        obj.queue_free()

    print_results("Node2D", count, sets.hash(), float(memory-bmu), set_time, get_time)

    #print("\nTest Results: Node2Ds -----------------------")
    #print("Number of instances: ", count)
    #print("    Memory usage: ", float(memory)/1_000_000, "mb")
    #print("")
    #print("Number of properties set: ", sets.size())
    #print("    Time to complete all sets: ", set_time)
    #print("    Average set time: ", set_time/sets.size())
    #print("")
    #print("Number of properties get: ", sets.size())
    #print("    Time to complete all gets: ", get_time)
    #print("    Average get time: ", get_time/sets.size())
    #print("----------------------------------------------\n")

func time_start() -> float:
    start_time = Time.get_unix_time_from_system()
    return start_time

func time_end() -> float:
    return Time.get_unix_time_from_system() - start_time

func print_results(object_type: String, object_count: int, sample_data_hash: int, memory: float, set_time: float, get_time: float):
    #print("| {0} | {1} | {2} | {3} | {4} | {5} |".format([object_type, object_count, sample_data_hash, snappedf(memory/1_000_000, 0.0001), snappedf(set_time*1e+9/ObjectSamples/SetSamples, 0.0001), snappedf(get_time*1e+9/ObjectSamples/SetSamples, 0.0001)]))
    output += ("| {0} | {1} | {2} | {3} | {4} | {5} |\n".format([object_type, object_count, sample_data_hash, snappedf(memory/1_000_000, 0.0001), snappedf(set_time*1e+9/ObjectSamples/SetSamples, 0.0001), snappedf(get_time*1e+9/ObjectSamples/SetSamples, 0.0001)]))

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


func _sets_to_ints(sets: Array[Dictionary]) -> Array[Dictionary]:
    for each in sets:
        match each.property:
            "editor_description":
                each.property = 0
            "name":
                each.property = 1
            "process_mode":
                each.property = 2
            "process_physics_priority":
                each.property = 3
            "process_priority":
                each.property = 4
            "process_thread_group_order":
                each.property = 5
            "scene_file_path":
                each.property = 6
    return sets


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
