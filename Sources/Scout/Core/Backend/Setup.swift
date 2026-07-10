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

    let install = UserDefaults.standard.ensure("scout_install_id")
    let launch = UUID()
    let device = KeychainStorage.standard.ensure("scout_device_id")
    let session = Protected(UUID())

    let identity = Identity(
        install: install,
        launch: launch,
        device: device,
        session: session
    )

    installExceptionHandler(identity: identity)
    installSignalHandler(identity: identity)
    installHangHandler(identity: identity)

    await CrashArchive.system.flush(deviceID: device)
    await HangArchive.system.flush(deviceID: device)

    try await persistentContainer.performBackgroundTasks(
        { try SessionObject.completeStale(launchID: launch, in: $0) },
        { try LaunchObject.completeStale(launchID: launch, in: $0) },
    )

    @Sendable func sync() async throws {
        try await synchronize(backends: backends, dispatcher: Coalescer())
    }

    ActionTable.appState(identity: identity).startListening(completion: sync)

    try await persistentContainer.performBackgroundTasks(
        { try DeviceObject.trigger(deviceID: device, in: $0) },
        { try InstallObject.trigger(installID: install, deviceID: device, in: $0) },
        { try VersionObject.trigger(installID: install, launchID: launch, in: $0) },
        { try LaunchObject.trigger(launchID: launch, installID: install, in: $0) },
        { try SessionObject.trigger(session: session, launchID: launch, in: $0) },
        { try UserActivityObject.trigger(sessionID: session.current, in: $0) },
        { try VersionMarker.trigger(installID: install, in: $0) }
    )

    LoggingSystem.bootstrap {
        CKLogHandler(sync: sync, session: session, label: $0)
    }
    MetricsSystem.bootstrap(
        TelemetryFactory(sync: sync, session: session)
    )

    isSetup = true
}
