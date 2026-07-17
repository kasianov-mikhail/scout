# Installation

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
.package(url: "https://github.com/kasianov-mikhail/scout.git", from: "3.3.0")
```

Then add `Scout` as a dependency for your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Scout", package: "scout")
    ]
)
```

## Enable CloudKit

Ensure CloudKit is enabled in your Apple Developer account and configured for your project. Refer to [Enabling CloudKit in Your App](https://developer.apple.com/documentation/cloudkit/enabling_cloudkit_in_your_app).

> Note: It may take some time for the database to become fully operational.

## Upload Your Database Schema

The CloudKit backend stores everything through [scout-db](https://github.com/kasianov-mikhail/scout-db)'s generic `Item`/`GridItem` schema. Upload its [schema file](https://github.com/kasianov-mikhail/scout-db/blob/main/Schema) to your CloudKit container:

1. Open the [CloudKit Console](https://icloud.developer.apple.com/dashboard/) and sign in with your Apple Developer account.
2. Select the CloudKit container associated with your project.
3. Go to the "Schema" section and use "Import Schema" to upload the schema file.
4. Click "Deploy to Production" to apply the schema.

Once CloudKit is enabled and the schema is uploaded, see the [Usage Guide](USAGE.md) for configuring `setup`, adding [Scout server](https://github.com/kasianov-mikhail/scout-server) backends, and writing logs and metrics.
