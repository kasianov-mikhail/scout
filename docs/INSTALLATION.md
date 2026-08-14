# Installation

## Table of Contents
- [Requirements](#requirements)
- [Add the Package](#add-the-package)
- [Enable CloudKit](#enable-cloudkit)
- [Upload Your Database Schema](#upload-your-database-schema)

## Requirements

- iOS 16.0+
- Swift 6.0+
- [Apple Developer](https://developer.apple.com) account with [CloudKit](https://developer.apple.com/icloud/cloudkit/) enabled

## Add the Package

In Xcode, go to **File > Add Package Dependencies…** and enter:

```
https://github.com/kasianov-mikhail/scout.git
```

Or add it to your `Package.swift`:

```swift
.package(url: "https://github.com/kasianov-mikhail/scout.git", from: "0.1.0")
```

Then add the products your target needs. `Scout` carries the runtime and the handlers; the backend it syncs to comes from a connector, so a CloudKit setup takes `NativeConnector` too:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Scout", package: "scout"),
        .product(name: "NativeConnector", package: "scout"),
    ]
)
```

The package publishes these products:

| Product | What it adds |
|-|-|
| `Scout` | The runtime, the log handler, the metrics factory, and crash reporting |
| `NativeConnector` | `Backend.cloudKit(container:)`, syncing to your CloudKit container |
| `HostedConnector` | `Backend.server(url:apiKey:)`, syncing to a [Scout server](https://github.com/kasianov-mikhail/scout-server) |
| `ScoutUI` | The in-app dashboard — see the [Dashboard Guide](DASHBOARD.md) |
| `LookupIndex` | A SwiftData record cache for the dashboard, enabled with `LookupIndex.enable()` on iOS 17+ |
| `DemoConnector` | `Backend.demo()`, an offline backend preloaded with fabricated data for previews and screenshots |

## Enable CloudKit

Ensure CloudKit is enabled in your Apple Developer account and configured for your project. Refer to [Enabling CloudKit in Your App](https://developer.apple.com/documentation/cloudkit/enabling_cloudkit_in_your_app).

> Note: It may take some time for the database to become fully operational.

## Upload Your Database Schema

The CloudKit backend stores everything through [scout-db](https://github.com/kasianov-mikhail/scout-db)'s generic `Item`/`GridItem` schema. Upload its [schema file](https://github.com/kasianov-mikhail/scout-db/blob/main/Schema) to your CloudKit container:

1. Open the [CloudKit Console](https://icloud.developer.apple.com/dashboard/) and sign in with your Apple Developer account.
2. Select the CloudKit container associated with your project.
3. Go to the "Schema" section and use "Import Schema" to upload the schema file.
4. Click "Deploy to Production" to apply the schema.

Once CloudKit is enabled and the schema is uploaded, see the [Usage Guide](USAGE.md) for creating the runtime, adding [Scout server](https://github.com/kasianov-mikhail/scout-server) backends, and writing logs and metrics.
