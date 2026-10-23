# Installation

## Table of Contents
- [Requirements](#requirements)
- [Add the Package](#add-the-package)
- [Enable CloudKit](#enable-cloudkit)
- [Upload Your Database Schema](#upload-your-database-schema)
- [Bundle Crash Symbols](#bundle-crash-symbols)

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
.package(url: "https://github.com/kasianov-mikhail/scout.git", from: "0.4.0")
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

## Bundle Crash Symbols

A release build is stripped, so a crash shows offsets like `MyApp + 0x1a2f10` instead of function names. A Run Script phase can turn each build's dSYM into a compact symbol table, `scout.scoutsym`, and put it in the app bundle:

1. In your app target, open **Build Phases**, add a **New Run Script Phase**, and move it to the end.
2. Set the script to the one in the Scout checkout:

   ```sh
   "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/scout/scripts/scout-symbols.sh"
   ```

   With a local copy of the package, point it at `scripts/scout-symbols.sh` in that folder.
3. Add this to **Input Files**, so the phase runs after Xcode writes the dSYM:

   ```
   ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${EXECUTABLE_NAME}
   ```

4. Add this to **Output Files**:

   ```
   ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/scout.scoutsym
   ```

5. Set **User Script Sandboxing** (`ENABLE_USER_SCRIPT_SANDBOXING`) to **No** for the target: the script builds the `scout-symbols` tool with SwiftPM.

The phase runs only when `DEBUG_INFORMATION_FORMAT` is `dwarf-with-dsym`, which is the default for Release. The first build also builds the tool and takes about half a minute; later builds add a few seconds.

Scout also reads the table on the launch after a crash or hang to name the app's frames before it groups the incident. Without the table, crashes in a stripped build that differ only in app frames share one issue.

To read a table by hand, `scout-symbols lookup scout.scoutsym 0x1a2f10` prints the function, file, and line at an offset, innermost inlined call first.

Once CloudKit is enabled and the schema is uploaded, see the [Usage Guide](USAGE.md) for creating the runtime, adding [Scout server](https://github.com/kasianov-mikhail/scout-server) backends, and writing logs and metrics.
