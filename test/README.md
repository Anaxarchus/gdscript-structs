## Benchmarks

### Hardware
- **CPU** Apple M2
- **Memory** 8gb

CPU: Apple M2
Times Averaged from 100 property queries in each of 1000 Object instances for a total of 100000 samples

| Type | **Count** | Data Hash | Usage (mb) | Set Time (nanoseconds) | Get Time (nanoseconds) |
|------|-------|-----------|------------|------------------------|------------------------|
| Struct (using property name) | 100,000 | 3970848985 | 5.274 | 397.861 | 340.9386 |
| Struct (using property index) | 100,000 | 3970848985 | 5.274 | 310.4997 | 242.5218 |
| Struct (using property name) | 250,000 | 3970848985 | 10.5168 | 388.391 | 333.8981 |
| Struct (using property index) | 250,000 | 3970848985 | 10.5168 | 302.1812 | 239.4414 |
| Struct (using property name) | 500,000 | 3970848985 | 21.0026 | 391.8791 | 331.7904 |
| Struct (using property index) | 500,000 | 3970848985 | 21.0026 | 306.1581 | 239.7895 |
| Struct (using property name) | 1,000,000 | 3970848985 | 41.9741 | 389.9813 | 325.911 |
| Struct (using property index) | 1,000,000 | 3970848985 | 41.9741 | 300.9081 | 233.9196 |
| Object | 100,000 | 3970848985 | 83.0951 | 294.7211 | 234.7708 |
| Object | 250,000 | 3970848985 | 288.0223 | 284.3404 | 229.1703 |
| Object | 500,000 | 3970848985 | 631.6052 | 284.1401 | 227.5801 |
| Object | 1,000,000 | 3970848985 | 1318.7312 | 293.6292 | 237 |
| Resource | 100,000 | 3970848985 | 95.9308 | 300.1285 | 245.0109 |
| Resource | 250,000 | 3970848985 | 319.9825 | 297.1482 | 248.22 |
| Resource | 500,000 | 3970848985 | 695.6052 | 307.4312 | 247.6692 |
| Resource | 1,000,000 | 3970848985 | 1446.7312 | 312.3999 | 247.7789 |
| Node | 100,000 | 3970848985 | 57.091 | 311.749 | 262.0792 |
| Node | 250,000 | 3970848985 | 222.9824 | 311.4796 | 260.5486 |
| Node | 500,000 | 3970848985 | 501.5654 | 315.969 | 265.1715 |
| Node | 1,000,000 | 3970848985 | 1058.7312 | 307.6601 | 256.6099 |
| Node2D | 100,000 | 3970848985 | 129.9021 | 316.2503 | 276.711 |
| Node2D | 250,000 | 3970848985 | 405.0104 | 325.1886 | 285.6207 |
| Node2D | 500,000 | 3970848985 | 865.6611 | 322.4516 | 284.6098 |
| Node2D | 1,000,000 | 3970848985 | 1786.8829 | 326.3783 | 289.6905 |


NOTE: all times are based on an average taken from 100 operations.

Each object type was given the following properties, if they didn't previously exist:
```
    var editor_description: String = "some description"
    var name: String = "TestObject"
    var process_mode: int = 1
    var process_physics_priority: int = 999
    var process_priority: int = 999
    var process_thread_group_order: int = 999
    var scene_file_path: String = "some/filepath/to/somewhere"
```
