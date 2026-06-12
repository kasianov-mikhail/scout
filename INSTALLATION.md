# Installation

## Enable CloudKit

Ensure CloudKit is enabled in your Apple Developer account and configured for your project. Refer to [Enabling CloudKit in Your App](https://developer.apple.com/documentation/cloudkit/enabling_cloudkit_in_your_app).

> Note: It may take some time for the database to become fully operational.

## Upload Your Database Schema

Upload the [schema file](https://github.com/kasianov-mikhail/scout/blob/main/Schema) to your CloudKit container:

1. Open the [CloudKit Console](https://icloud.developer.apple.com/dashboard/) and sign in with your Apple Developer account.
2. Select the CloudKit container associated with your project.
3. Go to the "Schema" section and use "Import Schema" to upload the schema file.
4. Click "Deploy to Production" to apply the schema.

## Configure Scout

```swift
import CloudKit
import Scout

let container = CKContainer(identifier: "YOUR_CONTAINER_ID")

try await setup(container: container)
```

## Using a Scout Server

Instead of CloudKit — or in addition to it — Scout can sync to one or more self-hosted [Scout servers](https://github.com/kasianov-mikhail/scout-server). A server needs no schema upload: it aggregates analytics natively.

```swift
try await setup(backends: [
    .cloudKit(container),
    .server(url: URL(string: "https://scout.example.com")!, apiKey: "YOUR_API_KEY"),
])
```

See the [server repository](https://github.com/kasianov-mikhail/scout-server) for deployment instructions and Docker images.
