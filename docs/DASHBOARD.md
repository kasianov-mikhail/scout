# Dashboard

## Table of Contents
- [Link the Product](#link-the-product)
- [Present the Dashboard](#present-the-dashboard)
- [Option 1: One Binary, Hidden Entry Point](#option-1-one-binary-hidden-entry-point)
- [Option 2: A TestFlight-Only Target or Branch](#option-2-a-testflight-only-target-or-branch)
- [Choosing](#choosing)

The dashboard ships as its own product, `ScoutUI`, separate from the `Scout` runtime. Recording logs, metrics, and crashes needs only `Scout` and a connector, so linking the dashboard is a deliberate step — and one you can take in the builds your testers run without taking it in the build you release.

## Link the Product

In `Package.swift`, add `ScoutUI` alongside the products you already depend on:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Scout", package: "scout"),
        .product(name: "NativeConnector", package: "scout"),
        .product(name: "ScoutUI", package: "scout"),
    ]
)
```

In an Xcode project, select the app target, open **General > Frameworks, Libraries, and Embedded Content**, and add `ScoutUI` from the Scout package.

## Present the Dashboard

`scoutHome(isPresented:backends:)` presents the whole dashboard as a full-screen cover on iOS (a sheet on macOS, which has no full-screen presentation). Pass the same `backends` array you gave to `Runtime` — the dashboard reads from the active one and offers a picker when there is more than one:

```swift
import ScoutUI
import SwiftUI

struct ContentView: View {
    @State private var isScoutPresented = false

    var body: some View {
        NavigationStack {
            InfoList()
                .toolbar {
                    Button {
                        isScoutPresented = true
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                    }
                }
                .scoutHome(isPresented: $isScoutPresented, backends: backends)
        }
    }
}
```

That leaves one decision: who gets to see the button. App Store users normally shouldn't, so the two setups below both aim the dashboard at TestFlight. They differ in whether `ScoutUI` ends up in the released binary at all.

## Option 1: One Binary, Hidden Entry Point

Link `ScoutUI` into the app target and gate the entry point instead of the framework. Debug builds always show it; a release build shows it only when it came from TestFlight, which the sandbox receipt reveals:

```swift
struct ScoutToolbarLink: View {
    @Binding var isPresented: Bool

    private var isVisible: Bool {
        #if DEBUG
            return true
        #else
            return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }

    var body: some View {
        if isVisible {
            Button {
                isPresented = true
            } label: {
                Image(systemName: "chart.bar.xaxis")
            }
            .accessibilityLabel("Scout")
        }
    }
}
```

The example app ships this file as [ScoutToolbarLink.swift](https://github.com/kasianov-mikhail/scout-ip/blob/main/ScoutIP/Components/ScoutToolbarLink.swift) and drops it into its toolbar next to the regular buttons.

The appeal is that a single binary goes through TestFlight and on to release, so the build your testers approved is the build your users get. The cost is that the dashboard's view code travels with it: the receipt check hides the button at runtime, it doesn't strip anything from the binary.

## Option 2: A TestFlight-Only Target or Branch

Keep `ScoutUI` out of the App Store build by linking it only where the dashboard is wanted, and compiling the entry point behind a flag.

Duplicate the app target — say `MyApp Scout` — link `ScoutUI` in that copy only, and add `SCOUT_UI` to its **Active Compilation Conditions**. Then guard the import and wrap the presentation in a modifier that collapses to nothing without the flag:

```swift
import Scout
import SwiftUI

#if SCOUT_UI
    import ScoutUI
#endif

extension View {
    func scoutDashboard(isPresented: Binding<Bool>, backends: [Backend]) -> some View {
        #if SCOUT_UI
            scoutHome(isPresented: isPresented, backends: backends)
        #else
            self
        #endif
    }
}
```

A dedicated branch achieves the same split without a second target: `main` builds the App Store release, and a long-lived branch adds the `ScoutUI` dependency and the entry point on top of it. Either way the App Store binary links only `Scout` and its connector, so none of the dashboard's view code is compiled into it.

Two things to weigh before choosing this. First, the build you release is not the build your testers ran — it differs by everything `ScoutUI` touches, and it reaches App Review as a separate build. Second, `ScoutAlerts` lives in `ScoutUI` too ([ScoutAlerts.swift](../Sources/ScoutUI/Monitoring/Alerts/Delivery/ScoutAlerts.swift)), so a build without the product also loses background alert evaluation; `registerBackgroundRefresh(backends:)` and `scheduleBackgroundRefresh()` have to sit behind the same flag as the dashboard.

## Choosing

Start with option 1. It is a few lines, it keeps one binary through the whole pipeline, and the dashboard is reachable in TestFlight the moment a tester needs it. Move to option 2 when binary size matters enough to pay for the split, or when you want a guarantee — not a runtime check — that no dashboard code ships to App Store users.
