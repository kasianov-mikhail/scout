# Installation

## Enable CloudKit

Ensure CloudKit is enabled in your Apple Developer account and configured for your project. Refer to [Enabling CloudKit in Your App](https://developer.apple.com/documentation/cloudkit/enabling_cloudkit_in_your_app).

> Note: It may take some time for the database to become fully operational.

## Upload Your Database Schema

Upload the [schema file](https://github.com/kasianov-mikhail/scout/blob/main/Schema) to your CloudKit container using one of the methods below.

### Option A: Using `cktool` (recommended)

`cktool` is included with Xcode. Create a [Management Token](https://developer.apple.com/help/account/manage-keys/create-a-cloudkit-management-token/) and save it:
```bash
xcrun cktool save-token
```

Then run the upload script included in the repository:
```bash
./upload-schema.sh <your-team-id> <your-container-id>
```

This uploads the schema to the development environment. To deploy to production, use the [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/).

### Option B: Using CloudKit Dashboard

1. Navigate to the [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/) and sign in with your Apple Developer account.
2. Choose the CloudKit container associated with your project.
3. In the CloudKit Dashboard, go to the "Schema" section and use the "Import Schema" option to upload the schema file.
4. Deploy the schema to production by clicking the "Deploy to Production" button.

## Configure Scout

```swift
import Scout

let container = CKContainer(identifier: "YOUR_CONTAINER_ID")

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
) -> Bool {
    try? Scout.setup(container: container)
    return true
}
```
