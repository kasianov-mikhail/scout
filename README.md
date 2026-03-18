<img width="1371" alt="logo" src="https://github.com/user-attachments/assets/9e27f4e8-603b-4ec5-b0b0-e3d2f8d0d8d9">

## Description
Scout is an iOS logging and analytics framework backed by CloudKit. It collects structured logs, metrics, and crash reports from your app and syncs them to a public CloudKit database where you can inspect them through a built-in SwiftUI dashboard.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Dashboard](#dashboard)
- [Example Project](#example-project)
- [License](#license)

## Features

| | Feature | Description |
|:-:|---------|-------------|
| 📝 | **Structured Logging** | Integrates with [swift-log](https://github.com/apple/swift-log). All log levels, labels, and metadata are persisted and synced automatically. |
| 📊 | **Metrics** | Integrates with [swift-metrics](https://github.com/apple/swift-metrics). Counters, timers, and floating-point counters are recorded alongside logs. |
| 💥 | **Crash Reporting** | Captures uncaught exceptions and signals (SIGABRT, SIGSEGV, etc.) with stack traces. Reports are flushed on the next launch. |
| ☁️ | **CloudKit Sync** | All data is stored locally with Core Data and synced to a public [CloudKit](https://developer.apple.com/icloud/cloudkit/) database. No custom backend required. |
| 📱 | **SwiftUI Dashboard** | A built-in `HomeView` with charts, event lists, crash details, and activity tracking for debugging in development builds. |

## Installation

Add the dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/kasianov-mikhail/scout.git", from: "2.0.0")
```

For CloudKit setup and schema upload, see the full [Installation Guide](INSTALLATION.md).

## Usage

Call `setup` once during app launch. This bootstraps logging, metrics, and crash reporting:
```swift
import CloudKit
import Scout

let container = CKContainer(identifier: "YOUR_CONTAINER_ID")

try await setup(container: container)
```

After setup, use the standard [swift-log](https://github.com/apple/swift-log) API to write logs:
```swift
import Logging

let logger = Logger(label: "MyApp")

logger.warning(
    "Search_Performed",
    metadata: [
        "description": .string(error.localizedDescription),
        "ip": .string(ip),
    ]
)
```

Metrics work the same way via [swift-metrics](https://github.com/apple/swift-metrics):
```swift
import Metrics

Counter(label: "api_requests").increment()
Timer(label: "response_time").recordSeconds(duration)
```

## Dashboard

Present `HomeView` to browse logs, metrics, crashes, and user activity:
```swift
HomeView(container: container)
```
> Use this only in debug builds to avoid exposing log data in production.

<img width="200" src="https://github.com/user-attachments/assets/0987c808-6d08-4e99-8ca7-1218d352e0bf"> <img width="200" src="https://github.com/user-attachments/assets/a70ae4d9-3680-48d3-8129-2febdc466030"> <img width="200" src="https://github.com/user-attachments/assets/6043911e-fd0b-4f6e-9785-c262dab1c6d7"> <img width="200" src="https://github.com/user-attachments/assets/dcec26e1-4e44-473c-b2e9-cde8ea2ffe2f">

## Example Project

See the [Scout IP](https://github.com/kasianov-mikhail/scout-ip) repository for a complete example app using Scout with CloudKit.

## License
Scout is released under the MIT License. See [LICENSE](LICENSE) for details.
