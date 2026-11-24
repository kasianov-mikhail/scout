# Usage

## Table of Contents
- [Bootstrap](#bootstrap)
- [Multiplexing Handlers](#multiplexing-handlers)
- [Multiple Backends](#multiple-backends)
- [Writing Logs](#writing-logs)
- [Recording Metrics](#recording-metrics)
- [Dashboard](#dashboard)

## Bootstrap

Create a runtime once during app launch and bootstrap the two handlers built on it. That wires logging, metrics, and crash reporting:
```swift
import CloudKit
import Logging
import Metrics
import NativeConnector
import Scout

let container = CKContainer(identifier: "YOUR_CONTAINER_ID")
let scout = Runtime(backends: [try Backend.cloudKit(container: container)])

LoggingSystem.bootstrap {
    ScoutLogHandler(label: $0, runtime: scout)
}
MetricsSystem.bootstrap(
    ScoutMetricsFactory(runtime: scout)
)
```
The runtime lives in the `Scout` product, while each backend comes from its own connector — `Backend.cloudKit(container:)` from `NativeConnector`. It throws when the container carries no identifier, which is what a default container resolves to in an app without an iCloud container entitlement.

Keep it to one runtime per app and pass the same one to both — a second runtime would install the crash handlers twice and open a second session against the same store. Creating it is synchronous, so the handlers work immediately; the lifecycle records and the first sync land shortly after. Passing an empty backend list turns Scout off — nothing is recorded or synced.

## Multiplexing Handlers

Scout claims no exclusive hold on either system, so you can multiplex it with handlers of your own. To keep logs in the Xcode console while debugging, add the stream handler that ships with swift-log:
```swift
LoggingSystem.bootstrap { label in
    MultiplexLogHandler([
        ScoutLogHandler(label: label, runtime: scout),
        StreamLogHandler.standardOutput(label: label),
    ])
}
```
Metrics compose the same way through `MultiplexMetricsHandler`. Note that both systems can only be bootstrapped once per process, so every handler you want has to be named in that single call.

## Multiple Backends

To sync somewhere other than CloudKit — or to several destinations at once — add more backends to the list. Every raw record is uploaded to every backend, and the dashboard reads from the first one:
```swift
import HostedConnector

let scout = Runtime(backends: [
    try Backend.cloudKit(container: container),
    Backend.server(url: URL(string: "https://scout.example.com")!, apiKey: "YOUR_API_KEY"),
])
```
Every backend receives the same raw records and aggregates them on its own side — the CloudKit backend through [scout-db](https://github.com/kasianov-mikhail/scout-db) views, a [Scout server](https://github.com/kasianov-mikhail/scout-server) natively. Unlike CloudKit, a Scout server needs no schema upload, and `Backend.server(url:apiKey:)` doesn't throw.

## Writing Logs

Once bootstrapped, use the standard [swift-log](https://github.com/apple/swift-log) API to write logs:
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
Loggers created before the bootstrap keep the handler they were built with, so create them afterwards.

## Recording Metrics

Metrics work the same way via [swift-metrics](https://github.com/apple/swift-metrics):
```swift
import Metrics

Counter(label: "api_requests").increment()
Timer(label: "response_time").recordSeconds(duration)
```

## Dashboard

To read the collected data back inside the app, link the `ScoutUI` product and present the dashboard — see the [Dashboard Guide](DASHBOARD.md).
