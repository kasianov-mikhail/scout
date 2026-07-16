//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Logging
import Metrics

@MainActor private var isSetup = false

/// Initializes Scout's global infrastructure against one or more backends.
///
/// Every raw record is synced to every backend. Aggregates are maintained
/// backend-side — by scout-db views on CloudKit and by native aggregation
/// on Scout servers — so clients upload raw records only.
///
/// - Parameter backends: The backends to sync to, in any combination of
///   CloudKit containers and Scout servers.
/// - Throws: An error if initialization fails or if called more than once.
/// - Important: Call from the main actor during app startup.
///
@MainActor
public func setup(backends: [Backend]) async throws {
    guard !isSetup else {
        throw SetupError.alreadySetup
    }
    guard !backends.isEmpty else {
        throw SetupError.noBackends
    }

    for backend in backends {
        backend.onSetup()
    }

    let session = Protected(UUID())

    let identity = Identity(
        install: UserDefaults.standard.ensure("scout_install_id"),
        launch: UUID(),
        device: KeychainStorage.standard.ensure("scout_device_id"),
        session: session
    )

    try await identity.bootstrap()

    let dispatcher = Coalescer()

    @Sendable func sync() async throws {
        try await synchronize(backends: backends, dispatcher: dispatcher)
    }

    identity.table.startListening(completion: sync)

    LoggingSystem.bootstrap {
        CKLogHandler(sync: sync, session: session, label: $0)
    }
    MetricsSystem.bootstrap(
        TelemetryFactory(sync: sync, session: session)
    )

    isSetup = true
}
