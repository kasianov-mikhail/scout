<p><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/ea52295b-30bd-47e9-bb3b-445585b22d8e"><img width="774" alt="Scout" src="https://github.com/user-attachments/assets/e936e3a2-63c8-4b1b-b3b2-4632041646dc"></picture></p>

[![CI](https://github.com/kasianov-mikhail/scout/actions/workflows/ci.yml/badge.svg)](https://github.com/kasianov-mikhail/scout/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/kasianov-mikhail/scout)](https://github.com/kasianov-mikhail/scout/releases)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange)
![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-blue)
[![License](https://img.shields.io/github/license/kasianov-mikhail/scout)](LICENSE)

## Description
Scout is an iOS logging and analytics framework backed by CloudKit. It collects structured logs, metrics, and crash reports from your app and syncs them to a public CloudKit database where you can inspect them through a built-in SwiftUI dashboard.

## Table of Contents
- [Features](#features)
- [Comparison](#comparison)
- [Installation](#installation)
- [Dashboard](#dashboard)
- [Roadmap](#roadmap)
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

## Comparison

How Scout compares to a hosted analytics SDK and to rolling your own backend:

<table>
<tr>
<th width="10%"></th>
<th width="30%">Scout (CloudKit)</th>
<th width="30%">Firebase</th>
<th width="30%">Custom backend</th>
</tr>
<tr>
<td><strong>Cost</strong></td>
<td><img src="https://img.shields.io/badge/Free-brightgreen?style=flat-square" alt="Free"><br>Free within <a href="https://developer.apple.com/icloud/cloudkit/">CloudKit's limits</a> — no servers to pay for, and the quota grows with your app</td>
<td><img src="https://img.shields.io/badge/Metered-yellow?style=flat-square" alt="Metered"><br>Free tier, then metered <a href="https://firebase.google.com/pricing">Blaze</a> billing as reads and traffic grow<br><br></td>
<td><img src="https://img.shields.io/badge/Paid-red?style=flat-square" alt="Paid"><br>Servers, database, and bandwidth billed from day one<br><br></td>
</tr>
<tr>
<td><strong>Data privacy</strong></td>
<td><img src="https://img.shields.io/badge/Private-brightgreen?style=flat-square" alt="Private"><br>Data stays in your own CloudKit container on Apple's infrastructure — no third-party analytics vendor</td>
<td><img src="https://img.shields.io/badge/Vendor--owned-red?style=flat-square" alt="Vendor-owned"><br>Data lives on Google's servers and can be linked across its ad and analytics products</td>
<td><img src="https://img.shields.io/badge/Your_responsibility-yellow?style=flat-square" alt="Your responsibility"><br>You control everything — and carry all the responsibility for securing it<br><br></td>
</tr>
<tr>
<td><strong>Infrastructure</strong></td>
<td><img src="https://img.shields.io/badge/Serverless-brightgreen?style=flat-square" alt="Serverless"><br>Zero servers — Apple runs the backend</td>
<td><img src="https://img.shields.io/badge/Managed-yellow?style=flat-square" alt="Managed"><br>Managed by Google, with vendor lock-in</td>
<td><img src="https://img.shields.io/badge/Self--hosted-red?style=flat-square" alt="Self-hosted"><br>You deploy and maintain it yourself</td>
</tr>
<tr>
<td><strong>Scaling</strong></td>
<td><img src="https://img.shields.io/badge/Automatic-brightgreen?style=flat-square" alt="Automatic"><br>Automatic, within the container quota</td>
<td><img src="https://img.shields.io/badge/Metered-yellow?style=flat-square" alt="Metered"><br>Automatic, but the bill scales too</td>
<td><img src="https://img.shields.io/badge/Manual-red?style=flat-square" alt="Manual"><br>Manual — you provision and pay for capacity</td>
</tr>
<tr>
<td><strong>Setup</strong></td>
<td><img src="https://img.shields.io/badge/Built--in-brightgreen?style=flat-square" alt="Built-in"><br>Already included with your Apple Developer account</td>
<td><img src="https://img.shields.io/badge/Setup_needed-yellow?style=flat-square" alt="Setup needed"><br>New project, SDK, and API keys</td>
<td><img src="https://img.shields.io/badge/Build_it-red?style=flat-square" alt="Build it"><br>Build the API, schema, and deployment</td>
</tr>
</table>

## Installation

To add the package and set up CloudKit, see the [Installation Guide](docs/INSTALLATION.md).

## Dashboard

The built-in SwiftUI dashboard lets you inspect logs, metrics, and crash reports right inside your development builds — browse charts, drill into event lists and crash details, and track activity over time without leaving the app.

It ships as a separate `ScoutUI` product, so you decide which builds carry it. See the [Dashboard Guide](docs/DASHBOARD.md) for linking it, presenting it, and keeping it out of the App Store build.

<p>
<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/5caab848-6cee-4ede-b752-763e71b9dd0c"><img width="240" alt="Home" src="https://github.com/user-attachments/assets/c0b30dfa-9bc1-4922-81f5-04a277bf4409"></picture>&emsp;&emsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/d39955b9-e418-477a-88c4-ac8ef51ddfc8"><img width="240" alt="Event" src="https://github.com/user-attachments/assets/e4534d46-5a02-458e-84cc-6db1ea537fb3"></picture>&emsp;&emsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/7bb0a797-0116-45e4-8812-90cc20aeddae"><img width="240" alt="Retention" src="https://github.com/user-attachments/assets/87e3b6da-864c-48b4-82a3-77f1644913b9"></picture>
</p>

<p>
<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/5ec37500-4500-4fe8-9795-5113f13fe113"><img width="240" alt="Crash" src="https://github.com/user-attachments/assets/e1713abc-0ba6-49c3-9847-2804c49fc070"></picture>&emsp;&emsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/6ae80fc8-18fc-4c22-a1f5-fbdd6028eb1e"><img width="240" alt="Metric distribution" src="https://github.com/user-attachments/assets/f4437bee-fbed-4b0b-a57c-0aa8f093b2cf"></picture>&emsp;&emsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/b6fed716-2c87-479e-b260-fe4fa71ad2c9"><img width="240" alt="Release health" src="https://github.com/user-attachments/assets/380b933a-43e1-45aa-b41a-5cf5da00a429"></picture>
</p>

## Roadmap

- [ ] **Hosted Scout** *(in progress)* — a managed [scout-server](https://github.com/kasianov-mikhail/scout-server) instance
- [ ] **AI tools** — an MCP server over the Scout backend
- [ ] **More platforms** — macOS, watchOS, tvOS, and visionOS
- [ ] **OpenTelemetry** — [OTLP](https://opentelemetry.io) support in both directions

Have an idea, or want one of these sooner? Open an [issue](https://github.com/kasianov-mikhail/scout/issues).

## License
Scout is released under the MIT License. See [LICENSE](LICENSE) for details.
