//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Logging
import Metrics

/// Initializes Scout's global infrastructure against one or more backends.
///
/// Every raw record is synced to every backend. Aggregates are maintained
/// backend-side — by scout-db views on CloudKit and by native aggregation
/// on Scout servers — so clients upload raw records only.
///
/// Passing no backends turns Scout off: nothing is bootstrapped, recorded,
/// or synced, and logs keep going wherever they went before.
///
/// - Parameter backends: The backends to sync to, in any combination of
///   CloudKit containers and Scout servers.
/// - Throws: An error if initialization fails.
/// - Important: Call from the main actor during app startup, exactly once —
///   `swift-log` and `swift-metrics` both trap on a second bootstrap.
///
@MainActor
public func setup(backends: [Backend]) async throws {
    guard backends.count > 0 else {
        return
    }

    let runtime = Runtime(backends: backends)

    LoggingSystem.bootstrap {
        ScoutLogHandler(runtime: runtime, label: $0)
    }
    MetricsSystem.bootstrap(
        TelemetryFactory(runtime: runtime)
    )

    try await runtime.start()
}
