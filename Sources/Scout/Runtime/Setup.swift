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
/// This is the one-line path, and it claims both logging and metrics for
/// Scout alone. Build a ``Runtime`` and bootstrap ``ScoutLogHandler``
/// and ``ScoutMetricsFactory`` yourself to multiplex Scout with handlers of
/// your own — a console handler while debugging, say, or an existing
/// logging stack.
///
/// Passing no backends turns Scout off: nothing is recorded or synced, and
/// logs keep going wherever they went before.
///
/// - Parameter backends: The backends to sync to, in any combination of
///   CloudKit containers and Scout servers.
/// - Throws: Nothing. The signature is kept so existing call sites keep
///   compiling while they move to the handlers.
/// - Important: Call from the main actor during app startup, exactly once —
///   `swift-log` and `swift-metrics` both trap on a second bootstrap.
///
@available(*, deprecated, message: "Bootstrap ScoutLogHandler and ScoutMetricsFactory instead")
@MainActor
public func setup(backends: [Backend]) async throws {
    let runtime = Runtime(backends: backends)

    LoggingSystem.bootstrap {
        ScoutLogHandler(label: $0, runtime: runtime)
    }
    MetricsSystem.bootstrap(
        ScoutMetricsFactory(runtime: runtime)
    )
}
