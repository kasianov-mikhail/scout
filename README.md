<img width="1371" alt="logo" src="https://github.com/user-attachments/assets/9e27f4e8-603b-4ec5-b0b0-e3d2f8d0d8d9">

A free, CloudKit-powered Firebase/Crashlytics alternative for indie developers. No third-party servers, zero maintenance cost.

[![Swift](https://github.com/kasianov-mikhail/scout/actions/workflows/swift.yml/badge.svg)](https://github.com/kasianov-mikhail/scout/actions/workflows/swift.yml)
[![codecov](https://codecov.io/gh/kasianov-mikhail/scout/branch/main/graph/badge.svg)](https://codecov.io/gh/kasianov-mikhail/scout)
[![Release](https://img.shields.io/github/v/release/kasianov-mikhail/scout)](https://github.com/kasianov-mikhail/scout/releases)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange)
![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-blue)
[![License](https://img.shields.io/github/license/kasianov-mikhail/scout)](LICENSE)

## Description
Scout is an iOS logging and analytics framework backed by CloudKit. It collects structured logs, metrics, and crash reports from your app and syncs them to a public CloudKit database where you can inspect them through a built-in SwiftUI dashboard.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Dashboard](#dashboard)
- [Example Project](#example-project)
- [License](#license)

## Features

| | | |
|:-:|-|-|
| 📝 | **Structured Logging** | Integrates with [swift-log](https://github.com/apple/swift-log). All log levels, labels, and metadata are persisted and synced automatically. |
| 📊 | **Metrics** | Integrates with [swift-metrics](https://github.com/apple/swift-metrics). Counters, timers, and floating-point counters are recorded alongside logs. |
| 💥 | **Crash Reporting** | Captures uncaught exceptions and signals (SIGABRT, SIGSEGV, etc.) with stack traces. Reports are flushed on the next launch. |
| ☁️ | **CloudKit Sync** | All data is stored locally with Core Data and synced to a public [CloudKit](https://developer.apple.com/icloud/cloudkit/) database. No custom backend required. |
| 🌐 | **Multiple Backends** | Sync to CloudKit, to one or more self-hosted [Scout servers](https://github.com/kasianov-mikhail/scout-server), or to any combination of them at once. |
| 📱 | **SwiftUI Dashboard** | A built-in dashboard with charts, event lists, crash details, and activity tracking for debugging in development builds. |

## Requirements

- iOS 16.0+
- Swift 6.0+
- [Apple Developer](https://developer.apple.com) account with [CloudKit](https://developer.apple.com/icloud/cloudkit/) enabled

## Installation

Add the dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/kasianov-mikhail/scout.git", from: "3.3.0")
```

For CloudKit setup and schema upload, see the full [Installation Guide](docs/INSTALLATION.md).

## Usage

Call `setup` once during app launch to bootstrap logging, metrics, and crash reporting, then write logs and metrics through the standard [swift-log](https://github.com/apple/swift-log) and [swift-metrics](https://github.com/apple/swift-metrics) APIs.

For the full walkthrough — backends, logging, and metrics — see the [Usage Guide](docs/USAGE.md).

## Dashboard

Attach `scoutHome(isPresented:backends:)` to a view to present the dashboard — logs, metrics, crashes, and user activity — over it. Drive it with a `Bool` binding and hand it the same backend list you passed to `setup`:
```swift
Button("Scout") { isPresented = true }
    .scoutHome(isPresented: $isPresented, backends: [.cloudKit(container)])
```
Or point it at a Scout server:
```swift
.scoutHome(isPresented: $isPresented, backends: [.server(url: serverURL, apiKey: "YOUR_API_KEY")])
```
> Use this only in debug builds to avoid exposing log data in production.

Every list and detail screen can also share its data as a Markdown document instead of a screenshot — see the [Exports Guide](docs/EXPORTS.md) for examples.

<img width="200" src="https://github.com/user-attachments/assets/0987c808-6d08-4e99-8ca7-1218d352e0bf"> <img width="200" src="https://github.com/user-attachments/assets/a70ae4d9-3680-48d3-8129-2febdc466030"> <img width="200" src="https://github.com/user-attachments/assets/6043911e-fd0b-4f6e-9785-c262dab1c6d7"> <img width="200" src="https://github.com/user-attachments/assets/dcec26e1-4e44-473c-b2e9-cde8ea2ffe2f">

## Example Project

See the [Scout IP](https://github.com/kasianov-mikhail/scout-ip) repository for a complete example app using Scout with CloudKit.

## License
Scout is released under the MIT License. See [LICENSE](LICENSE) for details.
