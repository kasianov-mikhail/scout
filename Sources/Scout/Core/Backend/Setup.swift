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
/// Every raw record is synced to every backend. CloudKit backends also
/// receive client-maintained matrix records; Scout servers aggregate
/// natively and receive raw metric values instead.
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

    installExceptionHandler()
    installSignalHandler()

    await CrashArchive.system.flush()

    try await persistentContainer.performBackgroundTasks(
        SessionObject.completeStale,
        LaunchObject.completeStale,
    )

    let dispatcher = Coalescer()

    @Sendable func sync() async throws {
        try await synchronize(backends: backends, dispatcher: dispatcher)
    }

    ActionTable.appState.startListening(completion: sync)

    try await persistentContainer.performBackgroundTasks(
        DeviceObject.trigger,
        InstallObject.trigger,
        VersionObject.trigger,
        LaunchObject.trigger,
        SessionObject.trigger,
        UserActivityObject.trigger,
        VersionMarker.trigger
    )

    LoggingSystem.bootstrap { CKLogHandler(sync: sync, label: $0) }
    MetricsSystem.bootstrap(TelemetryFactory(sync: sync))

    isSetup = true
}
