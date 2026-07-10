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
    installHangHandler()

    await CrashArchive.system.flush()
    await HangArchive.system.flush()

    let identity = GlobalIdentity.live

    try await persistentContainer.performBackgroundTasks(
        { try SessionObject.completeStale(identity: identity, in: $0) },
        { try LaunchObject.completeStale(identity: identity, in: $0) },
    )

    let dispatcher = Coalescer()

    @Sendable func sync() async throws {
        try await synchronize(backends: backends, dispatcher: dispatcher)
    }

    ActionTable.appState.startListening(completion: sync)

    try await persistentContainer.performBackgroundTasks(
        { try DeviceObject.trigger(identity: identity, in: $0) },
        { try InstallObject.trigger(identity: identity, in: $0) },
        { try VersionObject.trigger(identity: identity, in: $0) },
        { try LaunchObject.trigger(identity: identity, in: $0) },
        { try SessionObject.trigger(identity: identity, in: $0) },
        { try UserActivityObject.trigger(identity: identity, in: $0) },
        { try VersionMarker.trigger(identity: identity, in: $0) }
    )

    LoggingSystem.bootstrap { CKLogHandler(sync: sync, label: $0) }
    MetricsSystem.bootstrap(TelemetryFactory(sync: sync))

    isSetup = true
}
