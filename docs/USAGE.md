# Usage

Call `setup` once during app launch. This bootstraps logging, metrics, and crash reporting:
```swift
import CloudKit
import Scout

let container = CKContainer(identifier: "YOUR_CONTAINER_ID")

try await setup(container: container)
```

To sync somewhere other than CloudKit — or to several destinations at once — pass a list of backends instead. Every raw record is uploaded to every backend, and the dashboard reads from the first one:
```swift
try await setup(backends: [
    .cloudKit(container),
    .server(url: URL(string: "https://scout.example.com")!, apiKey: "YOUR_API_KEY"),
])
```
A [Scout server](https://github.com/kasianov-mikhail/scout-server) aggregates analytics natively, so it needs no schema upload and receives raw metric values instead of client-maintained matrices.

After setup, use the standard [swift-log](https://github.com/apple/swift-log) API to write logs:
```swift
import Logging

let logger = Logger(label: "MyApp")

logger.info(
    "Search_Performed",
    metadata: [
        "query": "coffee shops",
        "result_count": "12",
    ]
)
```

Metrics work the same way via [swift-metrics](https://github.com/apple/swift-metrics):
```swift
import Metrics

Counter(label: "api_requests").increment()
Timer(label: "response_time").recordSeconds(duration)
```
