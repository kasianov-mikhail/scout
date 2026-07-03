# Installation

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
