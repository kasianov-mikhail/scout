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
- [Comparison](#comparison)
- [Requirements](#requirements)
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

<img width="200" src="https://github.com/user-attachments/assets/0987c808-6d08-4e99-8ca7-1218d352e0bf"> <img width="200" src="https://github.com/user-attachments/assets/a70ae4d9-3680-48d3-8129-2febdc466030"> <img width="200" src="https://github.com/user-attachments/assets/6043911e-fd0b-4f6e-9785-c262dab1c6d7"> <img width="200" src="https://github.com/user-attachments/assets/dcec26e1-4e44-473c-b2e9-cde8ea2ffe2f">

## Comparison

How Scout compares to a hosted analytics SDK and to rolling your own backend:

![strength](https://img.shields.io/badge/strength-brightgreen?style=flat-square) &nbsp; ![trade-off](https://img.shields.io/badge/trade--off-yellow?style=flat-square) &nbsp; ![cost or burden](https://img.shields.io/badge/cost_or_burden-red?style=flat-square)

| | **Scout (CloudKit)**<br><img width="255" height="1" src="https://placehold.co/255x1/ffffff00/ffffff00.png"> | **Firebase**<br><img width="255" height="1" src="https://placehold.co/255x1/ffffff00/ffffff00.png"> | **Custom backend**<br><img width="255" height="1" src="https://placehold.co/255x1/ffffff00/ffffff00.png"> |
|-|-|-|-|
| **Cost** | ![Free](https://img.shields.io/badge/Free-brightgreen?style=flat-square)<br>Free within [CloudKit's limits](https://developer.apple.com/icloud/cloudkit/) — no servers to pay for, and the quota grows with your app | ![Metered](https://img.shields.io/badge/Metered-yellow?style=flat-square)<br>Free tier, then metered [Blaze](https://firebase.google.com/pricing) billing as reads and traffic grow | ![Paid](https://img.shields.io/badge/Paid-red?style=flat-square)<br>Servers, database, and bandwidth billed from day one |
| **Data privacy** | ![Private](https://img.shields.io/badge/Private-brightgreen?style=flat-square)<br>Data stays in your own CloudKit container on Apple's infrastructure — no third-party analytics vendor, and Apple doesn't mine it for advertising | ![Vendor-owned](https://img.shields.io/badge/Vendor--owned-red?style=flat-square)<br>Data lives on Google's servers and can be linked across its ad and analytics products | ![Your responsibility](https://img.shields.io/badge/Your_responsibility-yellow?style=flat-square)<br>You control everything — and carry all the responsibility for securing it |
| **Infrastructure** | ![Serverless](https://img.shields.io/badge/Serverless-brightgreen?style=flat-square)<br>Zero servers — Apple runs the backend | ![Managed](https://img.shields.io/badge/Managed-yellow?style=flat-square)<br>Managed by Google, with vendor lock-in | ![Self-hosted](https://img.shields.io/badge/Self--hosted-red?style=flat-square)<br>You deploy and maintain it yourself |
| **Scaling** | ![Automatic](https://img.shields.io/badge/Automatic-brightgreen?style=flat-square)<br>Automatic, within the container quota | ![Metered](https://img.shields.io/badge/Metered-yellow?style=flat-square)<br>Automatic, but the bill scales too | ![Manual](https://img.shields.io/badge/Manual-red?style=flat-square)<br>Manual — you provision and pay for capacity |
| **Setup** | ![Built-in](https://img.shields.io/badge/Built--in-brightgreen?style=flat-square)<br>Already included with your Apple Developer account | ![Setup needed](https://img.shields.io/badge/Setup_needed-yellow?style=flat-square)<br>New project, SDK, and API keys | ![Build it](https://img.shields.io/badge/Build_it-red?style=flat-square)<br>Build the API, schema, and deployment |

## Requirements

- iOS 16.0+
- Swift 6.0+
- [Apple Developer](https://developer.apple.com) account with [CloudKit](https://developer.apple.com/icloud/cloudkit/) enabled

To add the package and set up CloudKit, see the [Installation Guide](docs/INSTALLATION.md).

## License
Scout is released under the MIT License. See [LICENSE](LICENSE) for details.
